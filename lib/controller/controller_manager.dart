import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/controller/chat/writing_controller.dart';
import 'package:chat_interface/controller/current/notification_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:get/get.dart';

import 'chat/requests_controller.dart';

void initializeControllers() {
  
  Get.put(StatusController());
  Get.put(MessageController());
  Get.put(RequestController());
  Get.put(FriendController());
  Get.put(ConversationController());
  Get.put(WritingController());
  Get.put(NotificationController());
}