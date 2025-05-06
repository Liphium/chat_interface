import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';

void initializeControllers() {
  ConnectionController.init();
  SettingController.init();
  TrustedLinkHelper.init();
}
