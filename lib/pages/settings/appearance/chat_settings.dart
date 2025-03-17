import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatSettings {
  static const String chatTheme = "appearance.chat.theme";

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

  static void addSettings() {
    SettingController.addSetting(Setting<int>(chatTheme, 1));
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
          //* Chat theme
          Text("appearance.chat.theme".tr, style: Get.theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          ListSelectionSetting(
            setting: SettingController.settings[ChatSettings.chatTheme]! as Setting<int>,
            items: ChatSettings.chatThemes,
          ),
        ],
      ),
    );
  }
}
