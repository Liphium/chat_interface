import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/audio_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallControls extends StatefulWidget {
  const CallControls({super.key});

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {

  final _audioInputs = <MediaDevice>[].obs; // Will be used in the future
  final _audioOutputs = <MediaDevice>[].obs;

  StreamSubscription<dynamic>? subscription;

  @override
  void initState() {
    super.initState();

    /*
    subscription = Hardware.instance.onDeviceChange.stream.listen((event) {
      _updateDevices(event);
    });
    Hardware.instance.enumerateDevices().then((value) => _updateDevices(value)); */
  }

  void _updateDevices(List<MediaDevice> devices) {
    _audioInputs.clear();
    _audioInputs.addAll(devices.where((element) => element.kind == "audioinput").toList());

    _audioOutputs.clear();
    _audioOutputs.addAll(devices.where((element) => element.kind == "audiooutput").toList());
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing * 0.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            //* Microphone button
            GetX<AudioController>(
              builder: (controller) {
                return LoadingIconButton(
                  loading: controller.microphoneLoading,
                  onTap: () => controller.setMicrophone(!controller.microphone.value),
                  icon: controller.microphone.value ? Icons.mic_rounded : Icons.mic_off_rounded,
                  iconSize: 35,
                  color: theme.colorScheme.primary
                ); 
              },
            ),

            horizontalSpacing(defaultSpacing * 0.5),

            //* Audio output
            GetX<AudioController>(
              builder: (controller) {
                return LoadingIconButton(
                  loading: controller.outputLoading,
                  onTap: () => controller.setOutput(!controller.output.value),
                  icon: controller.output.value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  iconSize: 35,
                  color: theme.colorScheme.primary
                ); 
              },
            ),

            horizontalSpacing(defaultSpacing * 0.5),

            //* End call button
            LoadingIconButton(
              loading: false.obs,
              onTap: () => {} /* startCall(false.obs, Get.find<CallController>().conversation.value) */,
              icon: Icons.close_rounded,
              color: Colors.red.shade400,
              iconSize: 35,
            )
          ],
        ),
      ),
    );
  }
}