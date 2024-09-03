import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/publication_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_rotate_window.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallControls extends StatefulWidget {
  const CallControls({super.key});

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {
  final GlobalKey tabletopKey = GlobalKey();
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
    ThemeData theme = Get.theme;
    final controller = Get.find<SpacesController>();
    final tableController = Get.find<TabletopController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //* Microphone button
        GetX<PublicationController>(
          builder: (controller) {
            return LoadingIconButton(
              background: true,
              padding: defaultSpacing,
              loading: controller.muteLoading,
              onTap: () => controller.setMuted(!controller.muted.value),
              icon: controller.muted.value ? Icons.mic_off : Icons.mic,
              iconSize: 28,
              color: theme.colorScheme.onSurface,
            );
          },
        ),

        horizontalSpacing(defaultSpacing),

        //* Audio output
        GetX<PublicationController>(
          builder: (controller) {
            return LoadingIconButton(
              background: true,
              padding: defaultSpacing,
              loading: controller.deafenLoading,
              onTap: () => controller.setDeafened(!controller.deafened.value),
              icon: controller.deafened.value ? Icons.volume_off : Icons.volume_up,
              iconSize: 28,
              color: theme.colorScheme.onSurface,
            );
          },
        ),

        horizontalSpacing(defaultSpacing),

        //* Camera
        GetX<PublicationController>(
          builder: (controller) {
            return LoadingIconButton(
              background: true,
              padding: defaultSpacing,
              loading: controller.videoLoading,
              onTap: () => controller.setVideoEnabled(!controller.videoEnabled.value),
              icon: controller.videoEnabled.value ? Icons.videocam : Icons.videocam_off,
              iconSize: 28,
              color: theme.colorScheme.onSurface,
            );
          },
        ),

        /*
        horizontalSpacing(defaultSpacing),
    
        // Screenshare
        CallButtonBorder(
          child: GetX<PublicationController>(
            builder: (controller) {
              return LoadingIconButton(
                padding: defaultSpacing + elementSpacing,
                loading: controller.screenshareLoading,
                onTap: () async {
                  final sources = await desktopCapturer.getSources(types: [SourceType.Screen]);
                  if (sources.isNotEmpty) {
                    controller.setScreenshareEnabled(
                      !controller.screenshareEnabled.value,
                      options: ScreenShareCaptureOptions(
                        sourceId: sources.first.id,
                      ),
                    );
                  }
                  //sendLog(source);
                },
                icon: controller.videoEnabled.value ? Icons.stop_screen_share : Icons.screen_share,
                iconSize: 35,
                color: theme.colorScheme.onSurface,
              );
            },
          ),
        ),
        */

        horizontalSpacing(defaultSpacing),

        //* Table mode
        Obx(
          () => LoadingIconButton(
            background: true,
            padding: defaultSpacing,
            loading: tableController.loading,
            onTap: () {
              if (tableController.enabled.value) {
                tableController.disconnect();
              } else {
                tableController.connect();
              }
            },
            icon: tableController.enabled.value ? Icons.speaker_group : Icons.table_restaurant,
            iconSize: 28,
          ),
        ),

        //* Tabletop rotation button / Toggle people button
        Obx(
          () {
            if (tableController.enabled.value) {
              return Padding(
                padding: const EdgeInsets.only(left: defaultSpacing),
                child: LoadingIconButton(
                  key: tabletopKey,
                  background: true,
                  padding: defaultSpacing,
                  loading: false.obs,
                  onTap: () {
                    Get.dialog(TabletopRotateWindow(data: ContextMenuData.fromKey(tabletopKey, above: true)));
                  },
                  icon: Icons.crop_rotate,
                  iconSize: 28,
                ),
              );
            }

            if (controller.cinemaWidget.value != null) {
              return Padding(
                padding: const EdgeInsets.only(right: defaultSpacing),
                child: LoadingIconButton(
                  tooltip: "spaces.toggle_people".tr,
                  loading: false.obs,
                  padding: defaultSpacing,
                  background: true,
                  onTap: () => controller.hideOverlay.toggle(),
                  icon: controller.hideOverlay.value ? Icons.visibility_off : Icons.visibility,
                  iconSize: 28,
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),

        horizontalSpacing(defaultSpacing),

        //* End call button
        LoadingIconButton(
          background: true,
          padding: defaultSpacing,
          loading: false.obs,
          onTap: () => controller.leaveCall(),
          icon: Icons.call_end,
          color: theme.colorScheme.error,
          iconSize: 28,
        ),
      ],
    );
  }
}
