import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/spaces/warp/warp_manager_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:get/get.dart';

class WarpController extends GetxController {
  bool loading = false;

  /// Ports the current user is sharing as Warps
  final sharedWarps = <String, SharedWarp>{}.obs;

  /// Warps that the user is connected to.
  final activeWarps = <String, ConnectedWarp>{}.obs;

  /// Warps that are currently available (not connected) according to the server.
  final warps = <WarpShareContainer>[].obs;

  /// Create a Warp using the port it should share.
  ///
  /// This will tell the server about a port that this client wants to share with others in
  /// the Space. The connections to the local server will only start being opened once the
  /// first packet from the server arrives (they will be made on demand).
  ///
  /// This function doesn't do any validation since that's already happening in the WarpCreateWindow
  /// that calls this function.
  ///
  /// Returns an error if there was one.
  Future<String?> createWarp(int port) async {
    final event = await spaceConnector.sendActionAndWait(ServerAction("wp_create", port));
    if (event == null) {
      return "server.error".tr;
    }

    // Make sure the request was valid
    if (!event.data["success"]) {
      return event.data["message"];
    }

    // Add the Warp to the list of shared warps
    sharedWarps[event.data["id"]] = SharedWarp(event.data["id"], port);
    return null;
  }

  /// Stop a Warp and remove it from the list of shared Warps.
  void stopWarp(SharedWarp warp) {
    warp.stop();
    sharedWarps.remove(warp.id);
  }

  /// Connect to a Warp using its container.
  ///
  /// This will start an isolate that then tries to connect to every port on the local system.
  Future<void> connectToWarp(WarpShareContainer container) async {
    loading = true;

    // Scan for a port that is free on the current system
    final random = Random();
    int currentPort = container.port; // Start with the port that the sharer desired
    bool found = false;
    while (!found) {
      // Try connecting to the port
      try {
        await Socket.connect("localhost", currentPort);
        found = true;
      } catch (e) {
        // Generate a new random port
        currentPort = random.nextInt(65535 - 1024) + 1024;

        // This is just here in case this turns into an infinite loop and to prevent over-spinning
        await Future.delayed(Duration(milliseconds: 100));
      }
    }

    // Use the port that's been scanned above to start a socket for the Warp
    final warp = ConnectedWarp(container.id, container.port, currentPort, container.account);
    await warp.startServer();

    // Add the Warp to the list of active ones
    activeWarps[warp.id] = warp;

    loading = false;
  }

  /// Completely disconnect a Warp
  void disconnectWarp(ConnectedWarp warp) {
    warp.disconnectFromWarp();
    activeWarps.remove(warp.id);
  }

  /// This method gets called when a Warp ends according to the server.
  void onWarpEnd(String warp) {
    if (sharedWarps.containsKey(warp)) {
      return;
    }

    // Remove it from the list of Warps on the server
    warps.removeWhere((w) => w.id == warp);
  }

  /// Open Warp based on what it's currently doing.
  void open() {
    showModal(WarpManagerWindow());
  }
}

/// A Warp that has been shared by the user.
class SharedWarp {
  /// The id of the Warp (to identify it)
  final String id;

  /// The port being shared through Warp
  final int port;

  SharedWarp(this.id, this.port);

  /// All the current connections coming from clients
  final _sockets = <String, Map<int, Socket>>{};
  final _subs = <String, Map<int, StreamSubscription>>{};

  /// Send a packet from a client to the Warp.
  ///
  /// This will also open a new connection to the server in case there isn't one yet (for this client).
  Future<bool> receivePacketFromClient(String id, int connId, Uint8List bytes) async {
    if (_sockets[id] == null) {
      _sockets[id] = <int, Socket>{};
    }

    // Check if there is a connection already
    if (_sockets[id]![connId] == null) {
      // Create a new connection to the local server
      try {
        final socket = await Socket.connect("localhost", port);
        registerListener(id, connId, socket);
        _sockets[id]![connId] = socket;
      } catch (e) {
        return false;
      }
    }

    // Send the packet to the socket
    final socket = _sockets[id]![connId]!;
    socket.add(bytes);
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

    _subs[id]![connId] = socket.listen(
      (packet) => sendPacketToClient(id, connId, packet),
      onDone: () => removeClientFromWarp(id),
      cancelOnError: true,
    );
  }

  /// Send a packet to a client through the server.
  Future<void> sendPacketToClient(String id, int connId, Uint8List bytes) async {
    final event = await spaceConnector.sendActionAndWait(ServerAction("wp_send_back", {
      "w": this.id, // The parameter called "id" almost got me here xd
      "t": id,
      "c": connId,
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
    spaceConnector.sendAction(ServerAction("wp_kick", {
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
    _subs.remove(id);
    _sockets.remove(id);
  }

  /// Stop the Warp completely.
  ///
  /// Disconnects all clients + tells the server about the closure.
  void stop() {
    spaceConnector.sendAction(ServerAction("wp_end", id));

    // Disconnect all clients
    for (var map in _sockets.values) {
      for (var socket in map.values) {
        socket.close();
      }
    }
  }
}

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

  /// Start the server for proxying the connection.
  Future<void> startServer() async {
    server = await ServerSocket.bind("localhost", goalPort, shared: false);
    server!.listen(
      (socket) {
        // Increment the connection count and take current count as new identifier for this connection
        final currentId = connectionCount;
        _sockets[currentId] = socket;
        connectionCount++;

        // Listen to all packets from the socket
        StreamSubscription? sub;
        sub = socket.listen(
          (packet) async {
            // Forward the bytes to the server
            final result = await forwardBytesToHost(currentId, packet);
            if (!result) {
              disconnectFromWarp();
            }
          },
          onDone: () {
            sub?.cancel();
            _sockets.remove(currentId);
          },
          cancelOnError: true,
        );
      },
      onDone: () => disconnectFromWarp(),
      cancelOnError: true,
    );
  }

  /// Send bytes to the host server.
  Future<bool> forwardBytesToHost(int connId, Uint8List bytes) async {
    final event = await spaceConnector.sendActionAndWait(ServerAction("wp_send_to", {
      "w": id,
      "c": connId,
      "p": base64Encode(encryptSymmetricBytes(bytes, SpacesController.key!)),
    }));
    if (event == null || !event.data["success"]) {
      return false;
    }
    return true;
  }

  /// Forward a packet to a socket connected to the local server by their connection id
  Future<bool> forwardPacketToSocket(int connId, Uint8List bytes) async {
    if (_sockets[connId] == null) {
      return false;
    }

    // Forward the packet
    _sockets[connId]!.add(bytes);

    return true;
  }

  /// Disconnect from the Warp and close the local server.
  void disconnectFromWarp() {
    spaceConnector.sendAction(ServerAction("wp_disconnect", id));
    onDisconnect();
  }

  /// Called when the user gets disconnected.
  void onDisconnect() {
    server?.close();
  }
}

/// A container for a Warp that's being shared in a Space.
class WarpShareContainer {
  /// The id of the Warp (mainly used for identification)
  final String id;

  /// The port of the Warp.
  final int port;

  /// The person sharing the Warp.
  final Friend account;

  WarpShareContainer({
    required this.id,
    required this.account,
    required this.port,
  });
}
