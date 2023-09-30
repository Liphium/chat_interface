
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:get/get.dart';

Connector spaceConnector = Connector();

void createSpaceConnection(String domain, String token) {
  spaceConnector.connect("ws://$domain/gateway", token, restart: false, onDone: (() {
    Get.find<SpacesController>().leaveCall();
  }));
}

void setupSpaceListeners() {
  
  // Listen for room data changes
  spaceConnector.listen("room_data", (event) => handleRoomData(event)); // Sent on change
  spaceConnector.listen("room_info", (event) => handleRoomData(event)); // Sent on join
}

void handleRoomData(Event event) {
  final controller = Get.find<SpacesController>();
  controller.title.value = event.data["room"] == "" ? "space".tr : "";
  controller.start.value = DateTime.fromMillisecondsSinceEpoch(event.data["start"]);

  // Update members
  Get.find<SpaceMemberController>().onMembersChanged(event.data["members"]);
}