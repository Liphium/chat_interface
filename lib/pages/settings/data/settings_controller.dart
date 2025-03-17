import 'package:chat_interface/pages/chat/chat_page_mobile.dart';
import 'package:chat_interface/pages/settings/app/audio_settings.dart';
import 'package:chat_interface/pages/settings/app/general_settings.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/settings/app/log_settings.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/pages/settings/appearance/chat_settings.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/security/trusted_links_settings.dart';
import 'package:chat_interface/pages/settings/settings_page_desktop.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class AppSettings {
  static String showGroupMembers = "chat.group_members";
}

class SettingController {
  static final currentCategory = signal<SettingCategory?>(null); // For persisting the page in the settings
  static final settings = <String, Setting>{}; // label: Setting

  static void openSettingsPage() {
    if (isMobileMode()) {
      Get.offAll(ChatPageMobile(selected: 3));
    } else {
      Get.to(const SettingsPageDesktop());
    }
  }

  static void init() {
    GeneralSettings.addSettings();
    TabletopSettings.addSettings();
    ThemeSettings.addSettings();
    FileSettings.addSettings();
    TrustedLinkSettings.addSettings();
    ChatSettings.addSettings();
    LogSettings.addSettings();
    AudioSettings.addSettings();

    // Add app settings (not in settings page)
    addSetting(Setting<bool>(AppSettings.showGroupMembers, true));
  }

  static void addSetting(Setting setting) {
    settings[setting.label] = setting;
  }
}
