import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SettingsSetup extends Setup {
  SettingsSetup() : super('loading.settings', true);

  @override
  Future<Widget?> load() async {

    SettingController controller = Get.find();

    for (var setting in controller.settings.values) {
      setting.grabFromDb();
    }

    return null;
  }
}