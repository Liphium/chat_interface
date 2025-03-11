import 'package:chat_interface/controller/conversation/message_search_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:get/get.dart';

void initializeControllers() {
  // Conversation controls
  Get.put(MessageSearchController());

  // Account controls
  Get.put(ZapShareController());

  // App controls
  Get.put(ConnectionController());
  Get.put(SettingController());
  Get.put(ThemeManager());
  Get.put(TransitionController());

  StatusController.init();
  TrustedLinkHelper.init();
}
