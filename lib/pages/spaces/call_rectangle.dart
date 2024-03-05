import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/spaces/call_cinema.dart';
import 'package:chat_interface/pages/spaces/call_grid.dart';
import 'package:chat_interface/pages/spaces/call_page.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_rotate_window.dart';
import 'package:chat_interface/pages/spaces/widgets/call_controls.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class CallRectangle extends StatefulWidget {
  const CallRectangle({super.key});

  @override
  State<CallRectangle> createState() => _CallRectangleState();
}

class _CallRectangleState extends State<CallRectangle> {
  final controlsHovered = false.obs;
  final hovered = true.obs;
  Timer? timer;
  final GlobalKey tabletopKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SpacesController controller = Get.find();

    return Hero(
      tag: "call",
      child: Container(
        color: Get.theme.colorScheme.background,
        child: LayoutBuilder(builder: (context, constraints) {
          return MouseRegion(
            onEnter: (event) {
              hovered.value = true;
            },
            onHover: (event) {
              hovered.value = true;
              if (timer != null) timer?.cancel();
              timer = Timer(1000.ms, () {
                hovered.value = false;
              });
            },
            onExit: (event) {
              hovered.value = false;
              timer?.cancel();
            },
            child: Stack(
              children: [
                Obx(
                  () {
                    if (Get.find<TabletopController>().enabled.value) {
                      return const TabletopView();
                    }

                    if (controller.cinemaWidget.value != null) {
                      return const CallCinemaView();
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: CallGridView(constraints: constraints),
                        );
                      },
                    );
                  },
                ),

                //* People
                Align(
                  alignment: Alignment.topCenter,
                  child: Obx(
                    () => Visibility(
                      visible: Get.find<TabletopController>().enabled.value,
                      child: SizedBox(
                        height: 120,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.all(defaultSpacing),
                              child: CallGridView(constraints: constraints),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                //* Controls
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Obx(
                    () => Animate(
                      effects: [
                        FadeEffect(
                          duration: 150.ms,
                          end: 0.0,
                          begin: 1.0,
                        )
                      ],
                      target: hovered.value || controlsHovered.value ? 0 : 1,
                      child: Container(
                        // Create a gradient on this container from bottom to top
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0),
                            ],
                          ),
                        ),

                        child: MouseRegion(
                          onEnter: (event) => controlsHovered.value = true,
                          onExit: (event) => controlsHovered.value = false,
                          child: buildControls(controller),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget buildControls(SpacesController controller) {
    return Padding(
      padding: const EdgeInsets.only(
        right: sectionSpacing,
        left: sectionSpacing,
        bottom: sectionSpacing,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => LoadingIconButton(
              loading: false.obs,
              onTap: () {
                if (controller.playMode.value) {
                  showConfirmPopup(ConfirmWindow(
                      title: 'spaces.play_mode.leave',
                      text: 'spaces.play_mode.leave.text',
                      onConfirm: () {
                        Get.back();
                        Timer(300.ms, () {
                          controller.switchToPlayMode();
                        });
                      },
                      onDecline: () {
                        Get.back();
                      }));
                  return;
                }
                controller.fullScreen.toggle();
                if (controller.fullScreen.value) {
                  Get.offAll(const CallPage(), transition: Transition.fadeIn);
                } else {
                  Get.offAll(const ChatPage(), transition: Transition.fadeIn);
                }
              },
              icon: controller.fullScreen.value ? Icons.arrow_forward : Icons.arrow_back_rounded,
              iconSize: 30,
            ),
          ),
          const CallControls(),
          Obx(
            () {
              if (Get.find<TabletopController>().enabled.value) {
                return LoadingIconButton(
                  key: tabletopKey,
                  loading: false.obs,
                  onTap: () {
                    Get.dialog(TabletopRotateWindow(data: ContextMenuData.fromKey(tabletopKey, above: true)));
                  },
                  icon: Icons.crop_rotate,
                  iconSize: 30,
                );
              }

              return LoadingIconButton(
                loading: false.obs,
                onTap: () => controller.hideOverlay.toggle(),
                icon: controller.hideOverlay.value ? Icons.unfold_more : Icons.unfold_less,
                iconSize: 30,
              );
            },
          )
        ],
      ),
    );
  }
}
