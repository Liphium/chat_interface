import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:get/get.dart';

class WarpListener {
  static void setupWarpListeners() {
    // Listen for new Warps created on the server
    spaceConnector.listen("wp_new", (event) {
      // Add the container to the list of Warps on the server
      final controller = Get.find<SpaceMemberController>();
      final container = WarpShareContainer(
        id: event.data["w"],
        account: controller.members[event.data["h"]]!.friend,
        port: event.data["p"] as int,
      );
      Get.find<WarpController>().warps.add(container);
    });

    // Listen for the Warps that end
    spaceConnector.listen("wp_end", (event) {
      Get.find<WarpController>().onWarpEnd(event.data["w"]);
    });

    // Listen for packets meant for the local server (hoster -> current client)
    spaceConnector.listen("wp_to", (event) {
      // Get the Warp and make sure it's not null
      final warp = Get.find<WarpController>().activeWarps[event.data["w"]];
      if (warp == null) {
        return;
      }

      // Decrypt the content and forward
      final decrypted = decryptSymmetricBytes(base64Decode(event.data["p"]), SpacesController.key!);
      warp.forwardPacketToSocket(event.data["c"], decrypted, event.data["s"]);
    });

    // Listen for packets meant for the local server (current client -> hoster)
    spaceConnector.listen("wp_back", (event) {
      // Get the Warp and make sure it's not null
      final warp = Get.find<WarpController>().sharedWarps[event.data["w"]];
      if (warp == null) {
        return;
      }

      // Decrypt the content and handle receiving
      final decrypted = decryptSymmetricBytes(base64Decode(event.data["p"]), SpacesController.key!);
      warp.receivePacketFromClient(event.data["s"], event.data["c"], decrypted, event.data["sq"]);
    });

    // Listen for clients disconnecting from the shared server (as hoster)
    spaceConnector.listen("wp_disconnected", (event) {
      // Get the Warp and make sure it's not null
      final warp = Get.find<WarpController>().sharedWarps[event.data["w"]];
      if (warp == null) {
        return;
      }

      // Decrypt the content and handle receiving
      warp.handleDisconnect(event.data["c"]);
    });
  }
}
