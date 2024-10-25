import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralSettings {
  // Language settings
  static const String language = "language";
  static final languages = [
    LanguageSelection("Device", Icons.computer, Get.deviceLocale ?? const Locale("en", "US")),
    const LanguageSelection("English", Icons.language, Locale("en", "US")),
    //const LanguageSelection("Deutsch", Icons.language, Locale("de", "DE")), FUTURE STUFF
  ];

  // Notification sounds
  static const String soundsEnabled = "notification_sounds.enabled";
  static const String soundsDoNotDisturb = "notification_sounds.do_not_disturb";
  static const String soundsOnlyWhenTray = "notification_sounds.only_when_tray";
  static const String ringOnInvite = "ring.enable";
  static const String ringIgnoreTray = "ring.ignore_tray";

  static void addSettings(SettingController controller) {
    controller.settings[language] = Setting<int>(language, 0);

    // Default notification sounds settings
    controller.settings[soundsEnabled] = Setting(soundsEnabled, true);
    controller.settings[soundsDoNotDisturb] = Setting(soundsDoNotDisturb, false);
    controller.settings[soundsOnlyWhenTray] = Setting(soundsOnlyWhenTray, true);
    controller.settings[ringOnInvite] = Setting(ringOnInvite, true);
    controller.settings[ringIgnoreTray] = Setting(ringIgnoreTray, true);
  }
}

class LanguageSelection extends SelectableItem {
  final Locale locale;
  const LanguageSelection(super.label, super.icon, this.locale);
}

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "general",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Notification settings
          Row(
            children: [
              Text("settings.general.notifications".tr, style: Get.theme.textTheme.labelLarge),
              horizontalSpacing(defaultSpacing),
              LoadingIconButton(
                tooltip: "notification_sounds.tooltip".tr,
                padding: 0,
                extra: 3,
                color: Get.theme.colorScheme.onPrimary,
                icon: Icons.volume_up,
                onTap: () {
                  RingingManager.playNotificationSound();
                },
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),

          BoolSettingSmall(settingName: GeneralSettings.soundsEnabled),
          BoolSettingSmall(settingName: GeneralSettings.soundsDoNotDisturb),
          BoolSettingSmall(settingName: GeneralSettings.soundsOnlyWhenTray),
          verticalSpacing(sectionSpacing),

          //* Spaces ringtone
          Row(
            children: [
              Text("settings.general.ringtone".tr, style: Get.theme.textTheme.labelLarge),
              horizontalSpacing(defaultSpacing),
              LoadingIconButton(
                tooltip: "notification_sounds.tooltip".tr,
                padding: 0,
                extra: 3,
                color: Get.theme.colorScheme.onPrimary,
                icon: Icons.volume_up,
                onTap: () {
                  if (RingingManager.ringing) {
                    RingingManager.stopRingtone();
                  } else {
                    RingingManager.playRingSound();
                  }
                },
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          Text("ring.desc".tr, style: Get.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),

          BoolSettingSmall(settingName: GeneralSettings.ringOnInvite),
          BoolSettingSmall(settingName: GeneralSettings.ringIgnoreTray),
          verticalSpacing(sectionSpacing),

          //* Language selection
          Text("settings.general.language".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          ListSelectionSetting(
            settingName: "language",
            items: GeneralSettings.languages,
            callback: (language) {
              Get.updateLocale((language as LanguageSelection).locale);
            },
          ),
        ],
      ),
    );
  }
}
