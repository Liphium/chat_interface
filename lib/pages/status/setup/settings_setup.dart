import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/app/general_settings.dart';
import 'package:chat_interface/pages/settings/app/log_settings.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SettingsSetup extends Setup {
  SettingsSetup() : super('loading.settings', true);

  @override
  Future<Widget?> load() async {
    // Load all settings
    for (var setting in SettingController.settings.values) {
      await setting.grabFromDb();
    }

    // Set current language
    await Get.updateLocale(
      GeneralSettings.languages[SettingController.settings[GeneralSettings.language]!.getValue()].locale,
    );

    // Changes the color theme
    ThemeManager.changeTheme(getThemeData());

    // Initialize the tabletop settings
    await TabletopSettings.initSettings();

    // Delete old logs
    if (!isWeb) {
      final list = await LogManager.loggingDirectory!.list().toList();
      list.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      var index = SettingController.settings[LogSettings.amountOfLogs]!.getValue() as double;
      for (final file in list) {
        if (index <= 0) {
          await file.delete();
        }
        index--;
      }
    }

    sendLog("hi hi");

    return null;
  }
}
