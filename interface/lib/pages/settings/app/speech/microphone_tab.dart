import 'dart:async';

import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/pages/settings/app/speech/speech_settings.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class MicrophoneTab extends StatefulWidget {
  const MicrophoneTab({super.key});

  @override
  State<MicrophoneTab> createState() => _MicrophoneTabState();
}

class _MicrophoneTabState extends State<MicrophoneTab> {

  final _microphones = <InputDevice>[].obs;
  final _sensitivity = 0.0.obs;
  StreamSubscription? _sub;

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
    if(list.firstWhereOrNull((element) => element.id == currentMic) == null) {
      controller.settings["audio.microphone"]!.setValue("def");
    }

    _microphones.addAll(list);  
    await api.testVoice(device: _getCurrent());
    _sub = api.createAmplitudeStream().listen((amp) {
      _sensitivity.value = amp;
    });
  }

  String _getCurrent() {
    return Get.find<SettingController>().settings["audio.microphone"]!.getOr(SpeechSettings.defaultDeviceName);
  }

  void _changeMicrophone(String device) async {
    await api.stop();
    Get.find<SettingController>().settings["audio.microphone"]!.setValue(device);
    Future.delayed(500.ms, () async {
      await api.testVoice(device: _getCurrent());
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    api.deleteAmplitudeStream();
    api.stop();
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
        buildMicrophoneButton(controller, InputDevice(id: SpeechSettings.defaultDeviceName, sampleRate: 48000, bestQuality: false), BorderRadius.circular(defaultSpacing), icon: Icons.done_all, label: "audio.device.default.button".tr),
        verticalSpacing(defaultSpacing),

        Text("audio.microphone.device".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),

        RepaintBoundary(
          child: Obx(() =>
            ListView.builder(
              itemCount: _microphones.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final current = _microphones[index];

                final first = index == 0;
                final last = index == _microphones.length - 1;
                
                final radius = BorderRadius.vertical(
                  top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                  bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                );

                return buildMicrophoneButton(controller, current, radius);
              },
            )
          ),
        ),

        //* Start off muted
        const BoolSettingSmall(settingName: SpeechSettings.startMuted),
        
        verticalSpacing(sectionSpacing),
        
        //* Sensitivity
        Text("audio.microphone.sensitivity".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing * 0.5),

        RepaintBoundary(
          child: Obx(() =>
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("audio.microphone.sensitivity.text".tr, style: theme.textTheme.bodyMedium),
                SizedBox(height: 0, child: Opacity(opacity: 0, child: Text(_sensitivity.value.toString(), overflow: TextOverflow.clip,))),
                Slider(
                  value: clampDouble(sens.value.value, 0.0, 1.0),
                  min: 0.0,
                  max: 0.5,
                  inactiveColor: theme.colorScheme.onBackground,
                  thumbColor: theme.colorScheme.onPrimary,
                  activeColor: theme.colorScheme.onPrimary,
                  secondaryTrackValue: clampDouble(_sensitivity.value, 0.0, 0.5),
                  secondaryActiveColor: theme.colorScheme.secondary,
                  onChanged: (value) => sens.value.value = value,
                  onChangeEnd: (value) {
                    sens.setValue(value);
                  },
                ),
              ],
            ),
          ),
        ),
      
      ],
    );
  }

  Widget buildMicrophoneButton(SettingController controller, InputDevice current, BorderRadius radius, {IconData? icon, String? label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: elementSpacing * 0.5, horizontal: elementSpacing),
      child: Obx(() => 
        Material(
          color: controller.settings["audio.microphone"]!.getOr(SpeechSettings.defaultDeviceName) == current.id ? Get.theme.colorScheme.primary :
            Get.theme.colorScheme.onBackground,
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
                        Text(label ?? current.id, style: Get.theme.textTheme.labelMedium),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: current.bestQuality,
                    child: Icon(Icons.verified, color: Get.theme.colorScheme.secondary),
                  )
                ],
              )
            ),
          ),
        )
      ),
    );
  }
}