import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:get/get.dart';

// Action: fr_st
void friendStatusListener(Event event) async {
  FriendController controller = Get.find();

  // Set new status
  Friend friend = controller.friends[event.sender]!;
  friend.status.value = event.data["st"];
  friend.statusType.value = event.data["t"];
}