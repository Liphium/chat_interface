import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/services/spaces/warp/warp_connection.dart';
import 'package:chat_interface/services/spaces/warp/warp_shared.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:get/get.dart';

class WarpService {
  static void setupWarpListeners(Connector connector) {
    // Listen for new Warps created on the server
    connector.listen("wp_new", (event) {
      // Add the container to the list of Warps on the server
      final container = WarpShareContainer(
        id: event.data["w"],
        account: SpaceMemberController.getMember(event.data["h"])!.friend,
        port: event.data["p"] as int,
      );
      WarpController.addWarp(container);
    });

    // Listen for the Warps that end
    connector.listen("wp_end", (event) {
      WarpController.onWarpEnd(event.data["w"]);
    });

    // Listen for packets meant for the local server (hoster -> current client)
    connector.listen("wp_to", (event) {
      // Get the Warp and make sure it's not null
      WarpController.getActiveWarp(event.data["w"]);
      final warp = WarpController.getActiveWarp(event.data["w"]);
      if (warp == null) {
        return;
      }

      // Decrypt the content and forward
      final decrypted = decryptSymmetricBytes(base64Decode(event.data["p"]), SpaceController.key!);
      warp.forwardPacketToSocket(event.data["c"], decrypted, event.data["s"]);
    });

    // Listen for packets meant for the local server (current client -> hoster)
    connector.listen("wp_back", (event) {
      // Get the Warp and make sure it's not null
      final warp = WarpController.getSharedWarp(event.data["w"]);
      if (warp == null) {
        return;
      }

      // Decrypt the content and handle receiving
      final decrypted = decryptSymmetricBytes(base64Decode(event.data["p"]), SpaceController.key!);
      warp.receivePacketFromClient(event.data["s"], event.data["c"], decrypted, event.data["sq"]);
    });

    // Listen for clients disconnecting from the shared server (as hoster)
    connector.listen("wp_disconnected", (event) {
      // Get the Warp and make sure it's not null
      final warp = WarpController.getSharedWarp(event.data["w"]);
      if (warp == null) {
        return;
      }

      // Decrypt the content and handle receiving
      warp.handleDisconnect(event.data["c"]);
    });
  }

  /// Create a Warp using the port it should share.
  ///
  /// This will tell the server about a port that this client wants to share with others in
  /// the Space. The connections to the local server will only start being opened once the
  /// first packet from the server arrives (they will be made on demand).
  ///
  /// This function doesn't do any validation since that's already happening in the WarpCreateWindow
  /// that calls this function.
  ///
  /// Returns an error if there was one together with the created warp.
  static Future<(String?, SharedWarp?)> createWarp(int port) async {
    // Try connecting to the port to make sure there is a server there
    try {
      await Socket.connect("localhost", port);
    } catch (e) {
      return ("warp.error.port_not_used".tr, null);
    }

    final event = await SpaceConnection.spaceConnector!.sendActionAndWait(
      ServerAction("wp_create", port),
    );
    if (event == null) {
      return ("server.error".tr, null);
    }

    // Make sure the request was valid
    if (!event.data["success"]) {
      return (event.data["message"] as String, null);
    }

    // Return the warp to the controller
    return (null, SharedWarp(event.data["id"], port));
  }

  /// Connect to a Warp using its container.
  ///
  /// This will start an isolate that then tries to connect to every port on the local system.
  static Future<ConnectedWarp> connectToWarp(WarpShareContainer container) async {
    // Scan for a port that is free on the current system
    final random = Random();
    int currentPort = container.port; // Start with the port that the sharer desired
    bool found = false;
    while (!found) {
      // Try connecting to the port
      try {
        await Socket.connect("localhost", currentPort);

        // Generate a new random port
        currentPort = random.nextInt(65535 - 1024) + 1024;

        // This is just here in case this turns into an infinite loop and to prevent over-spinning
        await Future.delayed(Duration(milliseconds: 100));
      } catch (e) {
        found = true;
      }
    }

    // Use the port that's been scanned above to start a socket for the Warp
    final warp = ConnectedWarp(container.id, container.port, currentPort, container.account);
    await warp.startServer();

    return warp;
  }
}
