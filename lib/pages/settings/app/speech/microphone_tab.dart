import 'dart:async';

import 'package:chat_interface/controller/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/conversation/call/sensitvity_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class MicrophoneTab extends StatefulWidget {
  const MicrophoneTab({super.key});

  @override
  State<MicrophoneTab> createState() => _MicrophoneTabState();
}

class _MicrophoneTabState extends State<MicrophoneTab> {

  final _microphones = <MediaDevice>[].obs;
  StreamSubscription<List<MediaDevice>>? _subscription;

  @override
  void initState() {
    super.initState();

    // Get microphones
    Hardware.instance.enumerateDevices(type: "audioinput").then(_getMicrophones);

    // Subscribe to changes (e.g. unplugging a mic)
    _subscription = Hardware.instance.onDeviceChange.stream.listen(_getMicrophones);
  }

  void _getMicrophones(List<MediaDevice> list) {
    SettingController controller = Get.find();
    String currentMic = controller.settings["audio.microphone"]!.getValue();

    // Filter for microphones
    _microphones.clear();
    list.removeWhere((element) => element.kind != "audioinput");

    // If the current microphone is not in the list, set it to default
    if(list.firstWhereOrNull((element) => element.label == currentMic) == null) {
      controller.settings["audio.microphone"]!.setValue("def");
    }

    _microphones.addAll(list);

    if(!Get.find<CallController>().livekit.value) {
      Get.find<SensitivityController>().startListening();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();

    if(!Get.find<CallController>().livekit.value) {
      Get.find<SensitivityController>().stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {

    SettingController controller = Get.find();
    final sens = controller.settings["audio.microphone.sensitivity"]!;
    SensitivityController sensitivity = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpacing(defaultSpacing * 0.5),

        //* Device selection
        Text("audio.microphone.device".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing * 0.5),

        RepaintBoundary(
          child: Obx(() =>
            ListView.builder(
              itemCount: _microphones.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String current = _microphones[index].label;

                final first = index == 0;
                final last = index == _microphones.length - 1;
                
                final radius = BorderRadius.vertical(
                  top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                  bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.25, horizontal: defaultSpacing * 0.5),
                  child: Obx(() => 
                    Material(
                      color: controller.settings["audio.microphone"]!.getWhenValue("def", _microphones[0].label) == current ? theme.colorScheme.primaryContainer :
                        theme.colorScheme.onBackground,
                      borderRadius: radius,
                      child: InkWell(
                        borderRadius: radius,
                        onTap: () {
                          Get.find<SettingController>().settings["audio.microphone"]!.setValue(_microphones[index].label);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Row(
                            children: [
                              //* Icon
                              Icon(Icons.mic, color: theme.colorScheme.primary),

                              horizontalSpacing(defaultSpacing * 0.5),

                              //* Label
                              Text(_microphones[index].label, style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.onSurface
                              )),
                            ],
                          )
                        ),
                      ),
                    )
                  ),
                );
              },
            )
          ),
        ),
        verticalSpacing(defaultSpacing),

        //* Sensitivity
        Text("audio.microphone.sensitivity".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing * 0.5),

        Obx(() =>
          Column(
            children: [
              SizedBox(height: 0, child: Opacity(opacity: 0, child: Text(sensitivity.current.value.toString(), overflow: TextOverflow.clip,))),
              Slider(
                value: sens.value.value,
                min: -60,
                max: 0,
                divisions: 30,
                label: "${sens.value.value} dB",
                secondaryTrackValue: clampDouble(sensitivity.current.value, -60, 0),
                secondaryActiveColor: theme.colorScheme.secondary,
                onChanged: (value) => sens.value.value = value,
                onChangeEnd: (value) {
                  sens.setValue(value);
                },
              ),
            ],
          ),
        ),
      
      ],
    );
  }
}