import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:get/get.dart';

// Action: setup_st
void setupStatusListener(Event event) async {
  FriendController controller = Get.find();

  // Set new status
  for (var status in event.data["status"] ?? []) {
    controller.friends[status["account"]]?.status.value = status["status"];
    controller.friends[status["account"]]?.online.value = true;
  }

}

// Action: fr_st
void friendStatusListener(Event event) async {
  FriendController controller = Get.find();

  // Set new status
  controller.friends[event.sender]?.status.value = event.data["st"];
}