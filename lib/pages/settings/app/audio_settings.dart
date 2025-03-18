import 'dart:async';

import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/src/rust/api/audio_devices.dart' as libdevices;
import 'package:chat_interface/src/rust/api/engine.dart' as libspace;
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class AudioSettings {
  /// Value for the device selection to use the default device
  static final String useDefaultDevice = "def";

  /// The currently selected microphone
  static Setting<String> microphone = Setting("microphone", useDefaultDevice);

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

  /// The currently selected output device
  static Setting<String> outputDevice = Setting("output_device", useDefaultDevice);

  static void addSettings() {
    SettingController.addSetting(microphone);
    SettingController.addSetting(microphoneActivationMode);
    SettingController.addSetting(automaticVoiceActivity);
    SettingController.addSetting(microphoneSensitivity);

    SettingController.addSetting(outputDevice);
  }
}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {
  // State for the microphone selector
  final _microphones = listSignal<SelectableItem>([]);
  late final _selectedMicrophone = computed(() {
    // Try to find the currently selected device
    final selected = AudioSettings.microphone.getValue();
    int i = 0;
    for (var mic in _microphones.value) {
      // If it's currently selected, return the index
      if (mic.label == selected) {
        return i;
      }
      i++;
    }

    // Return index 0 (default microphone)
    return 0;
  });

  // State for the output device selector
  final _outputDevices = listSignal<SelectableItem>([]);
  late final _selectedOutputDevice = computed(() {
    // Try to find the currently selected output device
    final selected = AudioSettings.outputDevice.getValue();
    int i = 0;
    for (var device in _outputDevices.value) {
      // If it's currently selected, return the index
      if (device.label == selected) {
        return i;
      }
      i++;
    }

    // Return index 0 (default output device)
    return 0;
  });

  // State for the talking indicator
  final _speechDetected = signal(false);
  late final _talking = computed(() {
    if (AudioSettings.microphoneActivationMode.getValue() == 1) {
      return true;
    }

    return _speechDetected.value;
  });

  libspace.LightwireEngine? _engine;
  Timer? _timer;
  final _disposeFunctions = <void Function()>[];

  @override
  void initState() {
    initDevices();
    initLightwire();

    // Start a timer for updating the microphones (new ones might be plugged in)
    _timer = Timer.periodic(1.seconds, (timer) async {
      await _updateMicrophones();
      await _updateOutputDevices();
    });
    super.initState();
  }

  // Initialize the lightwire engine
  Future<void> initLightwire() async {
    _engine = await libspace.createLightwireEngine();

    // Start the engine
    libspace.startPacketStream(engine: _engine!).listen((packet) {
      final (_, speech) = packet;
      _speechDetected.value = speech;
    });
    await libspace.setVoiceEnabled(engine: _engine!, enabled: true);

    // Add subscriptions to automatically update the engine
    _disposeFunctions.add(AudioSettings.microphoneActivationMode.value.subscribe((value) {
      libspace.setActivityDetection(engine: _engine!, enabled: AudioSettings.microphoneActivationMode.getValue() == 0);
    }));
    await libspace.setActivityDetection(engine: _engine!, enabled: AudioSettings.microphoneActivationMode.getValue() == 0);
    _disposeFunctions.add(AudioSettings.automaticVoiceActivity.value.subscribe((value) {
      libspace.setAutomaticDetection(engine: _engine!, enabled: AudioSettings.automaticVoiceActivity.getValue());
    }));
    await libspace.setAutomaticDetection(engine: _engine!, enabled: AudioSettings.automaticVoiceActivity.getValue());
    _disposeFunctions.add(AudioSettings.microphoneSensitivity.value.subscribe((value) {
      libspace.setTalkingAmplitude(engine: _engine!, amplitude: AudioSettings.microphoneSensitivity.getValue());
    }));
    await libspace.setTalkingAmplitude(engine: _engine!, amplitude: AudioSettings.microphoneSensitivity.getValue());
  }

  /// Initialize the device lists
  Future<void> initDevices() async {
    await _updateMicrophones();
    await _updateOutputDevices();
  }

  /// Convert all the microphones from libspaceship to selectable items for the selector
  Future<void> _updateMicrophones() async {
    // Add the default microphone as a first option
    final defaultMicrophone = await libdevices.getDefaultInputDevice();
    final newList = <SelectableItem>[
      SelectableItem("Default (${defaultMicrophone.name})", Icons.mic),
    ];

    // Add all the other microphones
    for (var mic in await libdevices.getInputDevices()) {
      newList.add(SelectableItem(mic.name, Icons.mic));
    }

    // Only update in case necessary
    if (_microphones.value != newList) {
      _microphones.value = newList;
    }
  }

  /// Convert all the output devices from libspaceship to selectable items for the selector
  Future<void> _updateOutputDevices() async {
    // Add the default output device as a first option
    final defaultDevice = await libdevices.getDefaultOutputDevice();
    final newList = <SelectableItem>[
      SelectableItem("Default (${defaultDevice.name})", Icons.speaker),
    ];

    // Add all the other devices
    for (var device in await libdevices.getOutputDevices()) {
      newList.add(SelectableItem(device.name, Icons.speaker));
    }

    // Only update in case necessary
    if (_outputDevices.value != newList) {
      _outputDevices.value = newList;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _microphones.dispose();
    _selectedMicrophone.dispose();
    _outputDevices.dispose();
    _selectedOutputDevice.dispose();

    // Dispose all the subscriptions
    for (var func in _disposeFunctions) {
      func();
    }

    // Stop the engine
    if (_engine != null) {
      libspace.stopEngine(engine: _engine!);
    }

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
              items: _microphones.value,
              callback: (item, i) {
                if (i == 0) {
                  AudioSettings.microphone.setValue(AudioSettings.useDefaultDevice);
                } else {
                  AudioSettings.microphone.setValue(item.label);
                }
              },
            ),
          ),
          verticalSpacing(sectionSpacing),

          // Render a selection for the output device
          Text("settings.audio.output_device".tr, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Watch(
            (context) => ListSelection(
              selected: _selectedOutputDevice,
              items: _outputDevices.value,
              callback: (item, i) {
                if (i == 0) {
                  AudioSettings.outputDevice.setValue(AudioSettings.useDefaultDevice);
                } else {
                  AudioSettings.outputDevice.setValue(item.label);
                }
              },
            ),
          ),
          verticalSpacing(sectionSpacing),

          // The selection for the microphone activation mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("settings.audio.activation_mode".tr, style: theme.textTheme.labelLarge),
                  verticalSpacing(defaultSpacing),
                  Text("settings.audio.activation_mode.desc".tr, style: theme.textTheme.bodyMedium),
                  verticalSpacing(sectionSpacing),
                ],
              ),
              Watch(
                (ctx) => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _talking.value ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                  ),
                ),
              ),
            ],
          ),
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
          ),
        ],
      ),
    );
  }
}
