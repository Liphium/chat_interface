import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_message_listener.dart';
import 'package:chat_interface/connection/spaces/tabletop_listener.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:get/get.dart';

/// Connector the the space node.
Connector spaceConnector = Connector();

/// Connect to the space node.
Future<bool> createSpaceConnection(String domain, String token) async {
  return await spaceConnector.connect("${isHttps ? "wss://" : "ws://"}$domain/gateway", token, restart: false, onDone: ((error) {
    if (error) {
      showErrorPopup("error", "spaces.connection_error");
    }
    Get.find<SpacesController>().leaveCall(error: error);
  }));
}

/// Setup listeners for space events.
void setupSpaceListeners() {
  // Listen for room data changes
  spaceConnector.listen("room_data", (event) => handleRoomData(event)); // Sent on change
  spaceConnector.listen("room_info", (event) => handleRoomData(event)); // Sent on join
  spaceConnector.listen("member_update", (event) => handleMemberUpdate(event)); // Sent on member update

  setupTabletopListeners();
  setupSpaceMessageListeners();
}

void handleRoomData(Event event) {
  final controller = Get.find<SpacesController>();
  controller.start.value = DateTime.fromMillisecondsSinceEpoch(event.data["start"]);

  // Update members
  Get.find<SpaceMemberController>().onMembersChanged(event.data["members"]);
}

void handleMemberUpdate(Event event) {
  sendLog("member update");
  final controller = Get.find<SpaceMemberController>();
  final clientId = event.data["member"];
  final member = controller.members[clientId];
  if (member != null) {
    member.isMuted.value = event.data["muted"] ?? member.isMuted.value;
    member.isDeafened.value = event.data["deafened"] ?? member.isDeafened.value;
  }
}
