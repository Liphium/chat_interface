import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/app/language_settings.dart';
import 'package:chat_interface/pages/settings/app/spaces_settings.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/app/tabletop_settings.dart';
import 'package:chat_interface/pages/settings/app/video_settings.dart';
import 'package:chat_interface/pages/settings/appearance/call_settings.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/security/trusted_links_settings.dart';
import 'package:get/get.dart';

class AppSettings {
  static String showGroupMembers = "chat.group_members";
}

class SettingController extends GetxController {
  final settings = <String, Setting>{}; // label: Setting

  SettingController() {
    AudioSettings.addSettings(this);
    addVideoSettings(this);
    addCallAppearanceSettings(this);
    addLanguageSettings(this);
    SpacesSettings.addSpacesSettings(this);
    TabletopSettings.addSettings(this);
    ThemeSettings.addThemeSettings(this);
    FileSettings.addSettings(this);
    TrustedLinkSettings.registerSettings(this);
    ChatSettings.registerSettings(this);
    DataSettings.registerSettings(this);

    // Add app settings (not in settings page)
    addSetting(Setting<bool>(AppSettings.showGroupMembers, true));
  }

  void addSetting(Setting setting) {
    settings[setting.label] = setting;
  }
}
