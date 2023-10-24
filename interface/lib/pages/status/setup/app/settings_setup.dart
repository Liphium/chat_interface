import 'package:chat_interface/pages/settings/app/language_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SettingsSetup extends Setup {
  SettingsSetup() : super('loading.settings', true);

  @override
  Future<Widget?> load() async {

    SettingController controller = Get.find();

    // Load all settings
    for (var setting in controller.settings.values) {
      await setting.grabFromDb();
    }

    // Set current language
    sendLog("settings: " + controller.settings[LanguageSettings.language]!.getValue().toString());
    Get.updateLocale(LanguageSettings.languages[controller.settings[LanguageSettings.language]!.getValue()].locale);

    return null;
  }
}