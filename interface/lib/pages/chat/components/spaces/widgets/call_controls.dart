import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/audio_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallControls extends StatefulWidget {
  const CallControls({super.key});

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {

  StreamSubscription<dynamic>? subscription;

  @override
  void initState() {
    super.initState();
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
      color: theme.colorScheme.primaryContainer,
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
                  loading: controller.muteLoading,
                  onTap: () => controller.setMuted(!controller.muted.value),
                  icon: controller.muted.value ? Icons.mic_off : Icons.mic,
                  iconSize: 35,
                  color: theme.colorScheme.onSurface
                ); 
              },
            ),

            horizontalSpacing(defaultSpacing * 0.5),

            //* Audio output
            GetX<AudioController>(
              builder: (controller) {
                return LoadingIconButton(
                  loading: controller.deafenLoading,
                  onTap: () => controller.setDeafened(!controller.deafened.value),
                  icon: controller.deafened.value ? Icons.volume_off : Icons.volume_up,
                  iconSize: 35,
                  color: theme.colorScheme.onSurface
                ); 
              },
            ),

            horizontalSpacing(defaultSpacing * 0.5),

            //* End call button
            LoadingIconButton(
              loading: false.obs,
              onTap: () => Get.find<SpacesController>().leaveCall(),
              icon: Icons.close_rounded,
              color: theme.colorScheme.error,
              iconSize: 35,
            )
          ],
        ),
      ),
    );
  }
}