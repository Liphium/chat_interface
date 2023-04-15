import 'dart:async';

import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/chat/components/call/call_cinema.dart';
import 'package:chat_interface/pages/chat/components/call/call_grid.dart';
import 'package:chat_interface/pages/chat/components/call/call_page.dart';
import 'package:chat_interface/pages/chat/components/call/widgets/call_controls.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
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

  final int _people = 5;
  final _show = false.obs;

  Timer? timer;

  @override
  Widget build(BuildContext context) {

    CallController controller = Get.find();

    return Material(
      color: Colors.black,
      child: MouseRegion(
        onEnter: (_) {
          _show.value = true;
        },
        onHover: (_) {
          _show.value = true;
          timer?.cancel();
          timer = Timer(const Duration(seconds: 1), () {
            _show.value = false;
          });
        },
        onExit: (_) {
          _show.value = false;
        },
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                //* Participants
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Obx(() =>
                          !controller.cinema.value ?
                          CallGridView(constraints: constraints) :
                          const CallCinemaView()
                        ),
                      );
                    }
                  ),
                ),
            
                //* Controls
                Hero(
                  tag: "controls",
                  child: Obx(() => 
                    Visibility(
                      visible: !controller.hideOverlay.value,
                      child: callControls(controller)
                    )
                  ),
                )
            
              ]
            ),
            
            //* Overlay
            Obx(() => 
              Visibility(
                visible: controller.hideOverlay.value,
                child: Animate(
                  effects: const [
                    FadeEffect(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut
                    )
                  ],
                  target: _show.value ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.6),
                          ]
                        )
                      ),
                      child: callControls(controller)
                    )
                  ),
                )
              )
            )
      
          ],
        ),
      )
    );
  }

  Widget callControls(CallController controller) => Padding(
    padding: const EdgeInsets.all(defaultSpacing),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() =>
          LoadingIconButton(
            loading: false.obs,
            onTap: () {

              if(controller.fullScreen.value) {
                controller.expanded.value = true;
                controller.fullScreen.toggle();
                Get.offAll(const CallExpandedPage(), transition: Transition.fadeIn);
                return;
              }

              controller.expanded.toggle();

              if(controller.expanded.value) {
                Get.offAll(const CallExpandedPage(), transition: Transition.fadeIn);
              } else {
                Get.offAll(const ChatPage(), transition: Transition.fadeIn);
              }
            },
            icon: controller.fullScreen.value ? Icons.arrow_forward : !controller.expanded.value ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            iconSize: 35,
          ),
        ),

        const CallControls(),

        Obx(() =>
          LoadingIconButton(
            loading: false.obs,
            onTap: () {
              controller.fullScreen.toggle();

              if (controller.fullScreen.value) {
                Get.offAll(const CallPage(), transition: Transition.fadeIn);
              } else {
                if(controller.expanded.value) {
                  Get.offAll(const CallExpandedPage(), transition: Transition.fadeIn);
                } else {
                  Get.offAll(const ChatPage(), transition: Transition.fadeIn);
                }
              }
            },
            icon: !controller.fullScreen.value ? Icons.fullscreen_rounded : Icons.fullscreen_exit_rounded,
            iconSize: 35,
          ),
        ),
      ],
    ),
  );
}