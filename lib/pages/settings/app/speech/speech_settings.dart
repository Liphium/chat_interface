
import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/pages/settings/app/speech/microphone_tab.dart';
import 'package:chat_interface/pages/settings/app/speech/output_tab.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void addSpeechSettings(SettingController controller) {

  //* Microphone
  controller.settings["audio.microphone"] = Setting<String>("audio.microphone", "def");
  controller.settings["audio.microphone.sensitivity"] = Setting<double>("audio.microphone.sensitivity", -40.0);

  //* Output
  controller.settings["audio.output"] = Setting<String>("audio.output", "def");

}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {

  final _selected = "audio.microphone".obs;

  // Tabs
  final _tabs = <String, Widget>{
    "audio.microphone": const MicrophoneTab(),
    "audio.output": const OutputTab(),
  };

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.5),
          child: Text("settings.categories.audio".tr, style: theme.textTheme.headlineMedium),
        ),
        verticalSpacing(defaultSpacing),

        //* Tabs
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SidebarButton(
              onTap: () => _selected.value = "audio.microphone",
              radius: const BorderRadius.only(
                bottomLeft: Radius.circular(defaultSpacing),
              ),
              label: "audio.microphone",
              selected: _selected,
            ),
            horizontalSpacing(defaultSpacing * 0.5),
            SidebarButton(
              onTap: () => _selected.value = "audio.output",
              radius: const BorderRadius.only(
                topRight: Radius.circular(defaultSpacing),
              ),
              label: "audio.output",
              selected: _selected,
            )
          ]
        ),

        verticalSpacing(defaultSpacing),

        //* Current tab
        Obx(() =>
          _tabs[_selected.value]!
        )
      ],
    );
  }
}