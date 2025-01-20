import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/logging_framework.dart';

/// A Warp that has been shared by the user.
class SharedWarp {
  /// The id of the Warp (to identify it)
  final String id;

  /// The port being shared through Warp
  final int port;

  SharedWarp(this.id, this.port);

  /// All the current connections coming from clients
  final _sockets = <String, Map<int, Socket>>{};

  /// Completers to make sure packets aren't sent before the socket is connected
  final _completers = <String, Map<int, Completer<bool>>>{};

  // All the subscriptions made for the sockets (they need to be cancelled on disconnect)
  final _subs = <String, Map<int, StreamSubscription>>{};

  // All sequence related stuff for jitter buffering (can happen cause server)
  final _sequenceNumbers = <String, Map<int, int>>{};
  final _packetQueue = <String, Map<int, Map<int, Uint8List>>>{};

  /// Send a packet from a client to the Warp.
  ///
  /// This will also open a new connection to the server in case there isn't one yet (for this client).
  Future<bool> receivePacketFromClient(String id, int connId, Uint8List bytes, int seq) async {
    if (_sockets[id] == null) {
      sendLog("reset");

      // Initialize the socket storage and completers
      _sockets[id] = <int, Socket>{};
      _completers[id] = <int, Completer<bool>>{};

      // Initialize jitter buffering with correct values
      _packetQueue[id] = <int, Map<int, Uint8List>>{};
      _sequenceNumbers[id] = <int, int>{};
    }

    // Check if there is a connection already
    if (_sockets[id]![connId] == null) {
      // Make sure other packets wait
      _sequenceNumbers[id]![connId] = 0;
      final completer = Completer<bool>();
      _completers[id]![connId] = completer;

      // Create a new connection to the local server
      try {
        final socket = await Socket.connect("localhost", port);
        registerListener(id, connId, socket);
        _sockets[id]![connId] = socket;
        completer.complete(true);
      } catch (e) {
        sendLog("couldn't connect to local server: $e");
        completer.complete(false);
        return false;
      }
    }

    // Check if there is a completer to wait for
    if (_completers[id]![connId] != null) {
      final result = await _completers[id]![connId]!.future;
      if (!result) {
        return false;
      }
    }

    sendLog("received $connId $seq ${_sequenceNumbers[id]![connId]!}");

    // Check what the last sequence number was
    if (seq != _sequenceNumbers[id]![connId]! + 1) {
      if (_packetQueue[id]![connId] == null) {
        _packetQueue[id]![connId] = <int, Uint8List>{};
      }
      sendLog("packet queue $connId (share)");

      // Add the packet to the packet queue for now
      _packetQueue[id]![connId]![seq] = bytes;
      return true;
    } else {
      _sequenceNumbers[id]![connId] = seq;
    }

    // Send the packet to the socket
    final socket = _sockets[id]![connId]!;
    socket.add(bytes);
    sendLog("sending $connId $seq");

    // Check if there is a packet after it in the sequence queue
    while (_packetQueue[id]![connId]?[seq + 1] != null) {
      seq++;

      // Send the packet to the socket and remove it from the queue
      socket.add(_packetQueue[id]![connId]![seq]!);
      _packetQueue[id]![connId]!.remove(seq);

      sendLog("sending pq $connId $seq");

      // Update the sequence number accordingly
      _sequenceNumbers[id]![connId] = seq;
    }

    return true;
  }

  /// Register the listener that listens to the packets sent to the socket.
  ///
  /// This method will take all those packets and send them back to the other client
  /// through the server.
  void registerListener(String id, int connId, Socket socket) {
    if (_subs[id] == null) {
      _subs[id] = <int, StreamSubscription>{};
    }

    int seq = 1;
    _subs[id]![connId] = socket.listen(
      (packet) {
        sendPacketToClient(id, connId, packet, seq);
        seq++;
      },
      onError: (e) {
        removeClientFromWarp(id);
      },
      cancelOnError: true,
    );
  }

  /// Send a packet to a client through the server.
  Future<void> sendPacketToClient(String id, int connId, Uint8List bytes, int seq) async {
    final event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("wp_send_back", {
      "w": this.id, // The parameter called "id" almost got me here xd
      "t": id,
      "c": connId,
      "s": seq,
      "p": base64Encode(encryptSymmetricBytes(bytes, SpacesController.key!)),
    }));

    // Remove the client from the warp in case the response from the server is invalid (or there was an error)
    if (event == null || !event.data["success"]) {
      removeClientFromWarp(id);
      return;
    }
  }

  /// Disconnect a client from the Warp.
  ///
  /// This kicks them and blocks packets on the server side.
  void removeClientFromWarp(String id) {
    // Tell the server to kick the client
    SpaceConnection.spaceConnector!.sendAction(ServerAction("wp_kick", {
      "w": this.id,
      "t": id,
    }));

    // Disconnect them from the local server
    handleDisconnect(id);
  }

  /// Handle a client disconnect.
  ///
  /// This stops the client's connection to the local server.
  void handleDisconnect(String id) {
    if (_subs[id] != null) {
      for (var sub in _subs[id]!.values) {
        sub.cancel();
      }
    }
    if (_sockets[id] != null) {
      for (var socket in _sockets[id]!.values) {
        socket.close();
      }
    }
    _sequenceNumbers.remove(id);
    _packetQueue.remove(id);
    _subs.remove(id);
    _sockets.remove(id);
  }

  /// Stop the Warp completely.
  ///
  /// Disconnects all clients + tells the server about the closure.
  void stop({bool action = true}) {
    if (action) {
      SpaceConnection.spaceConnector!.sendAction(ServerAction("wp_end", id));
    }

    // Disconnect all clients
    for (var map in _sockets.values) {
      for (var socket in map.values) {
        socket.close();
      }
    }
  }
}
