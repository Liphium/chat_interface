import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/warp_controller.dart';
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
  }
}
