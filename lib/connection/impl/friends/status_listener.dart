import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:get/get.dart';

// Action: setup_st
void setupStatusListener(Event event) async {
  FriendController controller = Get.find();

  // Set new status
  for (var status in event.data["status"] ?? []) {
    controller.friends[status["account"]]?.status.value = status["status"];
    controller.friends[status["account"]]?.statusType.value = status["type"];
  }

  // Set own status
  StatusController statusController = Get.find();
  statusController.statusLoading.value = false;
  statusController.status.value = event.data["own_status"]!["status"];
  statusController.type.value = event.data["own_status"]!["type"];

}

// Action: fr_st
void friendStatusListener(Event event) async {
  FriendController controller = Get.find();

  // Set new status
  Friend friend = controller.friends[event.sender]!;
  friend.status.value = event.data["st"];
  friend.statusType.value = event.data["t"];
}