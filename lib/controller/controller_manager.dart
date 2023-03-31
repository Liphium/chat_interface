import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/controller/chat/account/writing_controller.dart';
import 'package:chat_interface/controller/chat/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/notification_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';

void initializeControllers() {
  
  Get.put(StatusController());
  Get.put(MessageController());
  Get.put(RequestController());
  Get.put(FriendController());
  Get.put(ConversationController());
  Get.put(WritingController());
  Get.put(NotificationController());
  Get.put(SettingController());
}