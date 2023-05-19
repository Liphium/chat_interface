import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/controller/chat/account/writing_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/call_member_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/microphone_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/output_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/screenshare_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/sensitvity_controller.dart';
import 'package:chat_interface/controller/chat/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/notification_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:get/get.dart';

void initializeControllers() {
  
  // Conversation controls
  Get.put(MessageController());
  Get.put(ConversationController());

  // Account controls
  Get.put(RequestController());
  Get.put(FriendController());
  Get.put(WritingController());

  // App controls
  Get.put(StatusController());
  Get.put(NotificationController());
  Get.put(SettingController());
  Get.put(ThemeManager());

  // Call controls
  Get.put(CallController());
  Get.put(ScreenshareController());
  Get.put(MicrophoneController());
  Get.put(PublicationController());
  Get.put(CallMemberController());
  Get.put(SensitivityController());
}