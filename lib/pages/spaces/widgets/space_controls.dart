import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/warp_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/spaces/call_page.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_rotate_window.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceControls extends StatefulWidget {
  const SpaceControls({super.key});

  @override
  State<SpaceControls> createState() => _SpaceControlsState();
}

class _SpaceControlsState extends State<SpaceControls> {
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

    return Center(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.only(
          right: sectionSpacing,
          left: sectionSpacing,
          bottom: sectionSpacing,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => LoadingIconButton(
                background: true,
                loading: false.obs,
                onTap: () {
                  controller.hideSidebar.toggle();
                  if (controller.hideSidebar.value) {
                    Get.offAll(const CallPage(), transition: Transition.fadeIn);
                  } else {
                    Get.offAll(const ChatPageDesktop(), transition: Transition.fadeIn);
                  }
                },
                icon: controller.hideSidebar.value ? Icons.arrow_forward : Icons.arrow_back,
                iconSize: 30,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tabletop rotation button
                    Obx(
                      () => Visibility(
                        visible: Get.find<SpacesController>().currentTab.value == SpaceTabType.table.index,
                        child: Padding(
                          padding: const EdgeInsets.only(right: defaultSpacing),
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
                        ),
                      ),
                    ),

                    // Full screen button
                    LoadingIconButton(
                      loading: false.obs,
                      background: true,
                      padding: defaultSpacing,
                      onTap: () => controller.toggleFullScreen(),
                      icon: controller.fullScreen.value ? Icons.fullscreen_exit : Icons.fullscreen,
                      iconSize: 28,
                    ),

                    horizontalSpacing(defaultSpacing),

                    // Warp manager button
                    LoadingIconButton(
                      loading: false.obs,
                      background: true,
                      padding: defaultSpacing,
                      onTap: () => Get.find<WarpController>().open(),
                      icon: Icons.cyclone,
                      iconSize: 28,
                    ),

                    horizontalSpacing(defaultSpacing),

                    // End space button
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
                ),
              ],
            ),
            const Spacer(),
            Obx(
              () {
                return LoadingIconButton(
                  loading: false.obs,
                  background: true,
                  onTap: () => controller.chatOpen.toggle(),
                  icon: controller.chatOpen.value ? Icons.arrow_forward : Icons.arrow_back,
                  iconSize: 30,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
