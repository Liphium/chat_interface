import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/spaces/call_grid.dart';
import 'package:chat_interface/pages/spaces/call_page.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/pages/spaces/widgets/call_controls.dart';
import 'package:chat_interface/pages/spaces/widgets/space_info_window.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
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
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    SpacesController controller = Get.find();

    return Hero(
      tag: "call",
      child: Container(
        color: Get.theme.colorScheme.background,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: [
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                //* Participants
                Expanded(
                  child: Obx(
                    () {
                      if (Get.find<TabletopController>().enabled.value) {
                        return const TabletopView();
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
                ),

                //* Controls
                Obx(
                  () => Visibility(
                    visible: !Get.find<TabletopController>().enabled.value,
                    child: buildControls(controller),
                  ),
                ),
              ]),

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
                  () => Visibility(
                    visible: Get.find<TabletopController>().enabled.value,
                    child: buildControls(controller),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildControls(SpacesController controller) {
    return Padding(
      padding: const EdgeInsets.all(defaultSpacing),
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
          LoadingIconButton(
            loading: false.obs,
            onTap: () => Get.dialog(const SpaceInfoWindow()),
            icon: Icons.info,
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}
