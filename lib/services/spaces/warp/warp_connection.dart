import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/logging_framework.dart';

/// A Warp that is being shared with the user and has been bound to a port.
class ConnectedWarp {
  /// The id of the Warp (to identify it)
  final String id;

  /// The port on the hoster's computer (for clarity when rendering)
  final int originPort;

  /// The port the server is being bound to on the local system
  final int goalPort;

  /// The friend that's hosting the Warp
  final Friend hoster;

  ConnectedWarp(this.id, this.originPort, this.goalPort, this.hoster);

  /// The server that proxies the connections.
  ServerSocket? server;

  /// The counter keeping track of the current connection number (for forwarding more efficiently)
  int connectionCount = 1;

  /// All the sockets that are currently connected to the local server
  final _sockets = <int, Socket>{};

  // All sequence related stuff for jitter buffering (can happen cause server)
  final _sequenceNumbers = <int, int>{};
  final _packetQueue = <int, Map<int, Uint8List>>{};

  /// Start the server for proxying the connection.
  Future<void> startServer() async {
    server = await ServerSocket.bind(InternetAddress.loopbackIPv4, goalPort, shared: false);

    sendLog("bound server on ${server!.address.toString()} ${server!.port}");

    server!.listen(
      (socket) {
        // Increment the connection count and take current count as new identifier for this connection
        final currentId = connectionCount;
        _sockets[currentId] = socket;
        connectionCount++;

        // Listen to all packets from the socket
        int seq = 0;
        StreamSubscription? sub;
        sub = socket.listen(
          (packet) async {
            // Forward the bytes to the server
            seq++;
            final result = await forwardBytesToHost(currentId, packet, seq);
            if (!result) {
              disconnectFromWarp();
            }
          },
          onDone: () {
            sub?.cancel();
            _sockets.remove(currentId);
          },
          onError: (e) {
            sendLog("disconnected cause $e");
          },
          cancelOnError: true,
        );
      },
      onDone: () => disconnectFromWarp(),
      onError: (e) {
        sendLog("warp ended cause $e");
      },
      cancelOnError: true,
    );
  }

  /// Send bytes to the host server.
  Future<bool> forwardBytesToHost(int connId, Uint8List bytes, int seq) async {
    final event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("wp_send_to", {
      "w": id,
      "s": seq,
      "c": connId,
      "p": base64Encode(encryptSymmetricBytes(bytes, SpaceController.key!)),
    }));
    if (event == null || !event.data["success"]) {
      return false;
    }
    return true;
  }

  /// Forward a packet to a socket connected to the local server by their connection id
  Future<bool> forwardPacketToSocket(int connId, Uint8List bytes, int seq) async {
    if (_sockets[connId] == null) {
      return false;
    }
    if (_packetQueue[connId] == null) {
      _packetQueue[connId] = <int, Uint8List>{};
      _sequenceNumbers[connId] = 0;
    }

    // Make sure it's the right sequence number
    if (seq != _sequenceNumbers[connId]! + 1) {
      _packetQueue[connId]![seq] = bytes;
      sendLog("packet queue (conn)");
      return true;
    } else {
      _sequenceNumbers[connId] = seq;
    }

    // Forward the packet
    _sockets[connId]!.add(bytes);

    // Check the queue for more packets after the current one
    while (_packetQueue[connId]![seq + 1] != null) {
      seq++;

      // Send the packet in the queue
      _sockets[connId]!.add(_packetQueue[connId]![seq]!);
      _packetQueue[connId]!.remove(seq);

      // Update the sequence number accordingly
      _sequenceNumbers[connId] = seq;
    }
    return true;
  }

  /// Disconnect from the Warp and close the local server.
  void disconnectFromWarp({bool action = true}) {
    if (action) {
      SpaceConnection.spaceConnector!.sendAction(ServerAction("wp_disconnect", id));
    }
    onDisconnect();
  }

  /// Called when the user gets disconnected.
  void onDisconnect() {
    for (var socket in _sockets.values) {
      socket.close();
    }
    server?.close();

    // Remove from the controller
    WarpController.removeActiveWarp(this);
  }
}
