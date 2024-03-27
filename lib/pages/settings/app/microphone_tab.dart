import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MicrophoneTab extends StatefulWidget {
  const MicrophoneTab({super.key});

  @override
  State<MicrophoneTab> createState() => _MicrophoneTabState();
}

class _MicrophoneTabState extends State<MicrophoneTab> {
  final _microphones = <api.InputDevice>[].obs;
  final _sensitivity = 0.0.obs;
  bool _started = false;
  StreamSubscription? _sub, _actionSub;

  @override
  void initState() {
    super.initState();

    // Get microphones
    _init();
  }

  void _init() async {
    final list = await api.listInputDevices();
    SettingController controller = Get.find();
    String currentMic = controller.settings["audio.microphone"]!.getValue();

    // If the current microphone is not in the list, set it to default
    if (list.firstWhereOrNull((element) => element.id == currentMic) == null) {
      controller.settings["audio.microphone"]!.setValue("def");
    }

    _microphones.addAll(list);
    if (!Get.find<SpacesController>().connected.value) {
      await api.testVoice(device: _getCurrent(), detectionMode: 0);
      _started = true;
    } else {
      await api.setAmplitudeLogging(amplitudeLogging: true);
    }
    _sub = api.createAmplitudeStream().listen((amp) {
      _sensitivity.value = amp;
    });
  }

  String _getCurrent() {
    return Get.find<SettingController>().settings[AudioSettings.microphone]!.getOr(AudioSettings.defaultDeviceName);
  }

  void _changeMicrophone(String device) async {
    Get.find<SettingController>().settings[AudioSettings.microphone]!.setValue(device);
    api.setInputDevice(id: device);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _actionSub?.cancel();
    api.setAmplitudeLogging(amplitudeLogging: false);
    api.deleteAmplitudeStream();
    if (_started) {
      api.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingController controller = Get.find();
    final sens = controller.settings["audio.microphone.sensitivity"]!;
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Device selection
        Text("audio.device".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Text("audio.device.default".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),
        buildMicrophoneButton(
          controller,
          api.InputDevice(id: AudioSettings.defaultDeviceName, displayName: AudioSettings.defaultDeviceName, sampleRate: 48000, bestQuality: false),
          BorderRadius.circular(defaultSpacing),
          icon: Icons.done_all,
          label: "audio.device.default.button".tr,
        ),
        verticalSpacing(defaultSpacing - elementSpacing),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("audio.device.custom".tr, style: theme.textTheme.bodyMedium),
            verticalSpacing(elementSpacing),
            RepaintBoundary(
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_microphones.length, (index) {
                    final current = _microphones[index];

                    final first = index == 0;
                    final last = index == _microphones.length - 1;

                    final radius = BorderRadius.vertical(
                      top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                      bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                    );

                    return buildMicrophoneButton(controller, current, radius);
                  }),
                ),
              ),
            ),
          ],
        ),

        //* Start off muted
        const BoolSettingSmall(settingName: AudioSettings.startMuted),
        verticalSpacing(sectionSpacing),

        //* Sensitivity
        Text("audio.microphone.sensitivity".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Text("audio.microphone.sensitivity.text".tr, style: theme.textTheme.bodyMedium),
        SizedBox(
          height: 0,
          child: Opacity(
            opacity: 0,
            child: Text(
              _sensitivity.value.toString(),
              overflow: TextOverflow.clip,
            ),
          ),
        ),
        verticalSpacing(defaultSpacing),

        ListSelectionSetting(
          settingName: AudioSettings.microphoneMode,
          items: AudioSettings.microphoneModes,
        ),

        RepaintBoundary(
          child: Obx(
            () {
              if (controller.settings[AudioSettings.microphoneMode]!.value.value == 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: defaultSpacing),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onBackground,
                      borderRadius: BorderRadius.circular(elementSpacing),
                    ),
                    height: 15,
                  ),
                );
              }

              return Slider(
                value: clampDouble(sens.value.value, -70, 0),
                min: -70,
                max: 0,
                label: _sensitivity.value.toString(),
                inactiveColor: theme.colorScheme.onBackground,
                thumbColor: theme.colorScheme.onPrimary,
                activeColor: theme.colorScheme.onPrimary,
                secondaryTrackValue: clampDouble(_sensitivity.value, -70, 0),
                secondaryActiveColor: theme.colorScheme.secondary,
                onChanged: (value) => sens.value.value = value,
                onChangeEnd: (value) {
                  sens.setValue(value);
                },
              );
            },
          ),
        ),

        verticalSpacing(sectionSpacing),

        //* Other settings
        Text("audio.microphone.processing".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
        Text("audio.microphone.processing.text".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),

        const BoolSettingSmall(settingName: AudioSettings.echoCancellation),
        const BoolSettingSmall(settingName: AudioSettings.noiseSuppression),
        const BoolSettingSmall(settingName: AudioSettings.autoGainControl),
        const BoolSettingSmall(settingName: AudioSettings.typingNoiseDetection),
        const BoolSettingSmall(settingName: AudioSettings.highPassFilter),
      ],
    );
  }

  Widget buildMicrophoneButton(SettingController controller, api.InputDevice current, BorderRadius radius, {IconData? icon, String? label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: elementSpacing),
      child: Obx(
        () => Material(
          color: controller.settings["audio.microphone"]!.getOr(AudioSettings.defaultDeviceName) == current.id
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.onBackground,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              _changeMicrophone(current.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        //* Icon
                        Icon(icon ?? Icons.mic, color: Get.theme.colorScheme.onPrimary),

                        horizontalSpacing(defaultSpacing * 0.5),

                        //* Label
                        Text(label ?? current.displayName, style: Get.theme.textTheme.labelMedium),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: current.bestQuality,
                    child: Icon(Icons.verified, color: Get.theme.colorScheme.secondary),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
