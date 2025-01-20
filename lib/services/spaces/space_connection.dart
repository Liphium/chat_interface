import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_message_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/connection/spaces/space_message_listener.dart';
import 'package:chat_interface/services/connection/spaces/tabletop_listener.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/services/spaces/warp/warp_service.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:get/get.dart';

class SpaceConnection {
  /// Connector the the space node.
  static Connector? spaceConnector;

  /// Connect to the space node.
  static Future<bool> createSpaceConnection(String domain, String token) async {
    spaceConnector = Connector();
    final success = await spaceConnector!.connect("${isHttps ? "wss://" : "ws://"}$domain/gateway", token, restart: false, onDone: ((error) {
      if (error) {
        showErrorPopup("error", "spaces.connection_error".tr);
      }

      // Tell all controllers about the leaving of the space
      Get.find<StatusController>().stopSharing();
      Get.find<TabletopController>().resetControllerState();
      SpacesController.leaveSpace(error: error);
      WarpController.resetControllerState();
      SpaceMemberController.onDisconnect();
      Get.find<SpacesMessageController>().clearProvider();
    }));

    // Setup all the listeners for the connector
    setupSpaceListeners();

    return success;
  }

  /// Disconnect from the Space.
  static void disconnect() {
    spaceConnector?.disconnect();
  }

  /// Setup listeners for space events.
  static void setupSpaceListeners() {
    // Listen for room data changes
    spaceConnector!.listen("room_data", (event) => _handleRoomData(event)); // Sent on change
    spaceConnector!.listen("room_info", (event) => _handleRoomData(event)); // Sent on join

    setupTabletopListeners();
    setupSpaceMessageListeners();
    WarpService.setupWarpListeners(spaceConnector!);
  }

  /// Sends the room data to all controllers
  static void _handleRoomData(Event event) {
    SpacesController.updateStartDate(DateTime.fromMillisecondsSinceEpoch(event.data["start"]));
    SpaceMemberController.onMembersChanged(event.data["members"]);
  }
}
