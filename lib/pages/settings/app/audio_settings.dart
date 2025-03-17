import 'dart:async';

import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
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
  static Setting<double> microphoneSensitivity = Setting("microphone.sensitivity", -50);

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
    // Try to find the currently selected device
    final selected = AudioSettings.microphone.getValue();
    int i = 0;
    for (var mic in _microphones) {
      // If it's currently selected, return the index
      if (mic.label == selected) {
        return i;
      }
      i++;
    }

    // Return index 0 (default microphone)
    return 0;
  });
  Timer? _timer;

  @override
  void initState() {
    // Start a timer for updating the microphones (new ones might be plugged in)
    _timer = Timer.periodic(1.seconds, (timer) {
      _microphones.value = _getMicrophones();
    });
    test();
    super.initState();
  }

  /// Convert all the microphones from libspaceship to selectable items for the selector
  List<SelectableItem> _getMicrophones() {
    final microphones = libspace.getInputDevices().map((mic) => SelectableItem(mic.name, Icons.mic)).toList();

    // Add the default microphone as a first option
    final defaultMicrophone = libspace.getDefaultInputDevice();
    microphones.insert(0, SelectableItem("Default (${defaultMicrophone.name})", Icons.mic));

    return microphones;
  }

  Future<void> test() async {
    final engine = await libspace.createLightwireEngine();
    final sink = libspace.startPacketEngine(engine: engine);
    sink.listen(
      (packet) {
        sendLog(packet.length);
      },
    );
    await libspace.setVoiceEnabled(engine: engine, enabled: true);
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
          // Render a list selection for the microphones
          Text("settings.audio.microphone".tr, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Watch(
            (context) => ListSelection(
              selected: _selectedMicrophone,
              items: _microphones,
              callback: (item, _) {
                AudioSettings.microphone.setValue(item.label);
              },
            ),
          ),
          verticalSpacing(sectionSpacing),

          // The selection for the microphone activation mode
          Text("settings.audio.activation_mode".tr, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("settings.audio.activation_mode.desc".tr, style: theme.textTheme.bodyMedium),
          verticalSpacing(sectionSpacing),
          ListSelectionSetting(
            setting: AudioSettings.microphoneActivationMode,
            items: AudioSettings.activationModes,
          ),
          verticalSpacing(defaultSpacing),

          // Only render automatic sensitivity detection when
          Watch(
            (ctx) => Visibility(
              visible: AudioSettings.microphoneActivationMode.getValue() == 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                child: BoolSettingSmall(settingName: AudioSettings.automaticVoiceActivity.label),
              ),
            ),
          ),

          // Only render the sensitivity slider in case automatic detection is off
          Watch(
            (ctx) => Visibility(
              visible: AudioSettings.microphoneActivationMode.getValue() == 0 && !AudioSettings.automaticVoiceActivity.getValue(),
              child: DoubleSelectionSetting(
                settingName: AudioSettings.microphoneSensitivity.label,
                description: "settings.audio.microphone.sensitivity.desc",
                min: -100,
                max: 0,
                unit: "dB",
              ),
            ),
          )
        ],
      ),
    );
  }
}
