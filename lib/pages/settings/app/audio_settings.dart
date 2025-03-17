import 'dart:async';

import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/src/rust/api/audio_devices.dart' as libspace;
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class AudioSettings {
  /// Value for the microphone setting to make it use the default microphone
  static final String useDefaultMicrophone = "def";

  /// The currently selected microphone
  static Setting<String> microphone = Setting("microphone", "def");

  /// The activation mode for the microphone
  static Setting<int> microphoneActivationMode = Setting("microphone.activation_mode", 0);

  /// All the activation modes for the microphone
  static final activationModes = <SelectableItem>[
    SelectableItem("microphone.mode.voice_activity", Icons.graphic_eq),
    SelectableItem("microphone.mode.always_on", Icons.radio_button_checked),
  ];

  /// If the sensitivity should be determined automatically
  static Setting<bool> automaticVoiceActivity = Setting("microphone.auto_activity", true);

  /// The threshold for the microphone to activate
  static Setting<double> microphoneSensitivity = Setting("microphone.sensitivity", -20);

  static void addSettings() {
    SettingController.addSetting(microphone);
    SettingController.addSetting(microphoneActivationMode);
    SettingController.addSetting(automaticVoiceActivity);
    SettingController.addSetting(microphoneSensitivity);
  }
}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {
  late final _microphones = listSignal<SelectableItem>(_getMicrophones());
  late final _selectedMicrophone = computed(() {
    final defaultDevice = libspace.getDefaultInputDevice();

    // Try to find the currently selected device
    final selected = AudioSettings.microphone.getValue();
    int i = 0;
    int defaultIndex = 0;
    for (var mic in _microphones) {
      // If it's currently selected, return the index
      if (mic.label == selected) {
        return i;
      }

      // If it's the default device, save the index for later
      if (mic.label == defaultDevice.name) {
        defaultIndex = i;
      }
      i++;
    }

    // Return the default index in case nothing was found
    return defaultIndex;
  });
  Timer? _timer;

  @override
  void initState() {
    sendLog(_getMicrophones());
    // Start a timer for updating the microphones (new ones might be plugged in)
    /*
    _timer = Timer.periodic(1.seconds, (timer) {
      _microphones.value = _getMicrophones();
    });
    */
    super.initState();
  }

  /// Convert all the microphones from libspaceship to selectable items for the selector
  List<SelectableItem> _getMicrophones() {
    return libspace.getInputDevices().map((mic) => SelectableItem(mic.name, Icons.mic)).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _microphones.dispose();
    _selectedMicrophone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SettingsPageBase(
      label: "audio",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading for the microphone settings
          Text("settings.audio.microphone".tr, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),

          // Render a list selection for the microphones
          Watch(
            (context) => ListSelection(
              selected: _selectedMicrophone,
              items: _microphones,
              callback: (item, _) {
                AudioSettings.microphone.setValue(item.label);
              },
            ),
          ),
        ],
      ),
    );
  }
}
