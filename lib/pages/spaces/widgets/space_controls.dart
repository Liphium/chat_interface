import 'dart:async';

import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_rotate_window.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

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
            Watch(
              (context) => LoadingIconButton(
                background: true,
                onTap: () => SidebarController.toggleSidebar(),
                icon: SidebarController.hideSidebar.value ? Icons.arrow_forward : Icons.arrow_back,
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
                    Watch(
                      (context) => Animate(
                        effects: [
                          ExpandEffect(
                            customHeightFactor: 1,
                            curve: Curves.ease,
                            duration: 250.ms,
                            axis: Axis.horizontal,
                            alignment: Alignment.center,
                          ),
                          FadeEffect(
                            duration: 250.ms,
                          ),
                          ScaleEffect(
                            duration: 250.ms,
                            curve: Curves.ease,
                          ),
                        ],
                        onInit: (ac) => ac.value = SpaceController.currentTab.value == SpaceTabType.table.index ? 1 : 0,
                        target: SpaceController.currentTab.value == SpaceTabType.table.index ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: defaultSpacing),
                          child: LoadingIconButton(
                            key: tabletopKey,
                            background: true,
                            padding: defaultSpacing,
                            loading: TabletopController.loading,
                            onTap: () {
                              Get.dialog(TabletopRotateWindow(data: ContextMenuData.fromKey(tabletopKey, above: true)));
                            },
                            icon: Icons.crop_rotate,
                            iconSize: 28,
                          ),
                        ),
                      ),
                    ),

                    // Full screen button (no reactivity needed cause refresh of the screen happens anyway)
                    LoadingIconButton(
                      background: true,
                      padding: defaultSpacing,
                      onTap: () => SpaceController.toggleFullScreen(),
                      icon: SpaceController.fullScreen.value ? Icons.fullscreen_exit : Icons.fullscreen,
                      iconSize: 28,
                    ),

                    horizontalSpacing(defaultSpacing),

                    // Render mute and deafen buttons in case in Studio
                    Watch((ctx) {
                      if (!StudioController.connected.value) {
                        return SizedBox();
                      }

                      return Row(
                        children: [
                          // Render the mute button
                          Watch(
                            (ctx) => LoadingIconButton(
                              loading: StudioController.audioStateLoading,
                              background: true,
                              padding: defaultSpacing,
                              onTap: () => StudioController.toggleMute(),
                              icon: StudioController.audioMuted.value ? Icons.mic_off : Icons.mic,
                              iconSize: 28,
                            ),
                          ),
                          horizontalSpacing(defaultSpacing),

                          // Render the deafen button
                          Watch(
                            (ctx) => LoadingIconButton(
                              loading: StudioController.audioStateLoading,
                              background: true,
                              padding: defaultSpacing,
                              onTap: () => StudioController.toggleDeafened(),
                              icon: StudioController.audioDeafened.value ? Icons.headset_off : Icons.headset,
                              iconSize: 28,
                            ),
                          ),
                          horizontalSpacing(defaultSpacing),
                        ],
                      );
                    }),

                    // Warp manager button
                    LoadingIconButton(
                      background: true,
                      padding: defaultSpacing,
                      onTap: () => WarpController.open(),
                      icon: Icons.cyclone,
                      iconSize: 28,
                    ),

                    horizontalSpacing(defaultSpacing),

                    // End space button
                    LoadingIconButton(
                      background: true,
                      padding: defaultSpacing,
                      onTap: () => SpaceController.leaveSpace(),
                      icon: Icons.call_end,
                      color: theme.colorScheme.error,
                      iconSize: 28,
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Watch(
              (context) {
                return LoadingIconButton(
                  background: true,
                  onTap: () => SpaceController.chatOpen.value = !SpaceController.chatOpen.peek(),
                  icon: SpaceController.chatOpen.value ? Icons.arrow_forward : Icons.arrow_back,
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
