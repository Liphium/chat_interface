
import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/pages/settings/app/speech/microphone_tab.dart';
import 'package:chat_interface/pages/settings/app/speech/output_tab.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpeechSettings {
  static String defaultDeviceName = "";
  static const String microphone = "audio.microphone";
  static const String microphoneSensitivity = "audio.microphone.sensitivity";
  static const String startMuted = "audio.microphone.muted";
  static const String output = "audio.output";
}

void addSpeechSettings(SettingController controller) async {

  SpeechSettings.defaultDeviceName = await api.getDefaultId();

  //* Microphone
  controller.settings[SpeechSettings.microphone] = Setting<String>(SpeechSettings.microphone, "def");
  controller.settings[SpeechSettings.microphoneSensitivity] = Setting<double>(SpeechSettings.microphoneSensitivity, 0.15);
  controller.settings[SpeechSettings.startMuted] = Setting<bool>(SpeechSettings.startMuted, false);

  //* Output
  controller.settings[SpeechSettings.output] = Setting<String>(SpeechSettings.output, "def");

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            horizontalSpacing(elementSpacing),
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

        verticalSpacing(sectionSpacing),

        //* Current tab
        Obx(() =>
          _tabs[_selected.value]!
        )
      ],
    );
  }
}