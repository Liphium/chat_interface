import 'dart:async';

import 'package:chat_interface/controller/spaces/studio/studio_device_manager.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
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
  static final activationModes = <SelectableItem>[
    SelectableItem("microphone.mode.voice_activity", Icons.graphic_eq),
    SelectableItem("microphone.mode.always_on", Icons.radio_button_checked),
  ];

  /// The bitrate for sending audio to the server
  static Setting<int> audioBitrateMode = Setting("audio.encoding.mode", 0);
  static final audioBitrateModes = <SelectableItem>[
    SelectableItem("audio.encoding.mode.auto", Icons.auto_awesome),
    SelectableItem("audio.encoding.mode.max", Icons.speed),
    SelectableItem("audio.encoding.mode.high", Icons.signal_cellular_alt),
    SelectableItem("audio.encoding.mode.medium", Icons.signal_cellular_alt_2_bar),
    SelectableItem("audio.encoding.mode.low", Icons.signal_cellular_alt_1_bar),
  ];

  /// All the activation modes for the microphone

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

  static void applyBitrate(libspace.LightwireEngine engine) {
    switch (audioBitrateMode.getValue()) {
      case 0:
        libspace.setEncodingBitrate(engine: engine, auto: true, max: false, bitrate: 0);
      case 1:
        libspace.setEncodingBitrate(engine: engine, auto: false, max: true, bitrate: 0);
      case 2:
        libspace.setEncodingBitrate(engine: engine, auto: false, max: false, bitrate: 144000);
      case 3:
        libspace.setEncodingBitrate(engine: engine, auto: false, max: false, bitrate: 96000);
      case 4:
        libspace.setEncodingBitrate(engine: engine, auto: false, max: false, bitrate: 40000);
    }
  }

  /// Apply all the audio settings to a lightwire engine.
  ///
  /// Returns all the dispose functions for the signals.
  static Future<List<Function()>> subscribeToSettings(libspace.LightwireEngine engine) async {
    final list = <Function()>[];

    list.add(
      AudioSettings.microphoneActivationMode.value.subscribe((value) {
        libspace.setActivityDetection(engine: engine, enabled: AudioSettings.microphoneActivationMode.getValue() == 0);
      }),
    );
    await libspace.setActivityDetection(
      engine: engine,
      enabled: AudioSettings.microphoneActivationMode.getValue() == 0,
    );
    list.add(
      AudioSettings.automaticVoiceActivity.value.subscribe((value) {
        libspace.setAutomaticDetection(engine: engine, enabled: AudioSettings.automaticVoiceActivity.getValue());
      }),
    );
    await libspace.setAutomaticDetection(engine: engine, enabled: AudioSettings.automaticVoiceActivity.getValue());
    list.add(
      AudioSettings.microphoneSensitivity.value.subscribe((value) {
        libspace.setTalkingAmplitude(engine: engine, amplitude: AudioSettings.microphoneSensitivity.getValue());
      }),
    );
    await libspace.setTalkingAmplitude(engine: engine, amplitude: AudioSettings.microphoneSensitivity.getValue());
    list.add(
      AudioSettings.audioBitrateMode.value.subscribe((mode) {
        AudioSettings.applyBitrate(engine);
      }),
    );
    AudioSettings.applyBitrate(engine);

    return list;
  }
}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {
  // State for the talking indicator
  final _speechDetected = signal(false);
  late final _talking = computed(() {
    if (AudioSettings.microphoneActivationMode.getValue() == 1) {
      return true;
    }

    return _speechDetected.value;
  });

  final _engine = signal<libspace.LightwireEngine?>(null);
  final _disposeFunctions = <void Function()>[];

  @override
  void initState() {
    initLightwire();
    super.initState();
  }

  // Initialize the lightwire engine
  Future<void> initLightwire() async {
    _engine.value = await libspace.createLightwireEngine();

    // Start the engine
    libspace.startPacketStream(engine: _engine.peek()!).listen((packet) {
      final (_, _, speech) = packet;
      _speechDetected.value = speech ?? false;
    });

    // Set the selected devices
    await libspace.setInputDevice(engine: _engine.peek()!, device: AudioSettings.microphone.getValue());
    await libspace.setOutputDevice(engine: _engine.peek()!, device: AudioSettings.microphone.getValue());

    // Add subscriptions to automatically update the engine
    _disposeFunctions.addAll(await AudioSettings.subscribeToSettings(_engine.peek()!));

    // Enable the packet sending
    await libspace.setVoiceEnabled(engine: _engine.peek()!, enabled: true);
  }

  @override
  void dispose() {
    // Dispose all the subscriptions
    for (var func in _disposeFunctions) {
      func();
    }

    // Stop the engine
    if (_engine.peek() != null) {
      libspace.stopEngine(engine: _engine.peek()!);
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
          Watch((ctx) => _engine.value == null ? SizedBox() : MicrophoneSelection(engine: _engine.value!)),
          verticalSpacing(sectionSpacing),

          // Render a selection for the output device
          Text("settings.audio.output_device".tr, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Watch((ctx) => _engine.value == null ? SizedBox() : OutputDeviceSelection(engine: _engine.value!)),
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
          ListSelectionSetting(setting: AudioSettings.microphoneActivationMode, items: AudioSettings.activationModes),
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
              visible:
                  AudioSettings.microphoneActivationMode.getValue() == 0 &&
                  !AudioSettings.automaticVoiceActivity.getValue(),
              child: DoubleSelectionSetting(
                settingName: AudioSettings.microphoneSensitivity.label,
                description: "settings.audio.microphone.sensitivity.desc",
                min: -100,
                max: 0,
                unit: "dB",
              ),
            ),
          ),
          verticalSpacing(sectionSpacing),

          // Render a selection for the encoding mode
          Text("settings.audio.advanced".tr, style: theme.textTheme.labelLarge),
          verticalSpacing(defaultSpacing),
          Text("audio.encoding.mode".tr, style: theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          ListSelectionSetting(setting: AudioSettings.audioBitrateMode, items: AudioSettings.audioBitrateModes),
        ],
      ),
    );
  }
}

class MicrophoneSelection extends StatelessWidget {
  final libspace.LightwireEngine engine;
  final bool secondary;

  const MicrophoneSelection({super.key, required this.engine, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Watch((ctx) {
      // Make sure to show a message in case there are no devices
      if (StudioDeviceManager.microphones.value.isEmpty) {
        return Text("settings.audio.devices_empty".tr, style: theme.textTheme.bodyMedium);
      }

      return ListSelection(
        selected: StudioDeviceManager.selectedMicrophone,
        items: StudioDeviceManager.microphones.value,
        secondary: secondary,
        callback: (item, i) {
          if (i == 0) {
            AudioSettings.microphone.setValue(AudioSettings.useDefaultDevice);
          } else {
            AudioSettings.microphone.setValue(item.label);
          }
          libspace.setInputDevice(engine: engine, device: AudioSettings.microphone.getValue());
        },
      );
    });
  }
}

class OutputDeviceSelection extends StatelessWidget {
  final libspace.LightwireEngine engine;
  final bool secondary;

  const OutputDeviceSelection({super.key, required this.engine, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Watch((ctx) {
      // Make sure to show a message in case there are no devices
      if (StudioDeviceManager.outputDevices.value.isEmpty) {
        return Text("settings.audio.devices_empty".tr, style: theme.textTheme.bodyMedium);
      }

      return ListSelection(
        selected: StudioDeviceManager.selectedOutputDevice,
        items: StudioDeviceManager.outputDevices.value,
        secondary: secondary,
        callback: (item, i) {
          if (i == 0) {
            AudioSettings.outputDevice.setValue(AudioSettings.useDefaultDevice);
          } else {
            AudioSettings.outputDevice.setValue(item.label);
          }
          libspace.setOutputDevice(engine: engine, device: AudioSettings.outputDevice.getValue());
        },
      );
    });
  }
}
