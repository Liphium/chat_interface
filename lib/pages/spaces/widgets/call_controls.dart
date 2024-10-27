import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_rotate_window.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        //* Tabletop rotation button / Toggle people button
        Obx(
          () {
            if (controller.currentTab.value == SpaceTabType.table.index) {
              return Padding(
                padding: const EdgeInsets.only(left: defaultSpacing),
                child: LoadingIconButton(
                  key: tabletopKey,
                  background: true,
                  padding: defaultSpacing,
                  loading: Get.find<TabletopController>().loading,
                  onTap: () {
                    Get.dialog(TabletopRotateWindow(data: ContextMenuData.fromKey(tabletopKey, above: true)));
                  },
                  icon: Icons.crop_rotate,
                  iconSize: 28,
                ),
              );
            }

            if (controller.currentTab.value == SpaceTabType.cinema.index) {
              return Padding(
                padding: const EdgeInsets.only(left: defaultSpacing),
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
