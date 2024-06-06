import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatSettings {
  static const String chatTheme = "appearance.chat.theme";
  static final Setting<int> chatThemeSetting = Setting<int>(chatTheme, 1);

  static final chatThemes = <SelectableItem>[
    SelectableItem(
      "appearance.chat.theme.material".tr,
      Icons.view_list,
      experimental: true,
    ),
    SelectableItem(
      "appearance.chat.theme.bubbles".tr,
      Icons.comment,
    ),
  ];

  static void registerSettings(SettingController controller) {
    controller.settings[chatTheme] = chatThemeSetting;
  }
}

class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "chat",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Auto download types
          Text("appearance.chat.theme".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          ListSelectionSetting(
            settingName: ChatSettings.chatTheme,
            items: ChatSettings.chatThemes,
          ),
        ],
      ),
    );
  }
}
