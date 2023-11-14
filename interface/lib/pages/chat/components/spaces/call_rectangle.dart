import 'dart:async';
import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_grid.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_page.dart';
import 'package:chat_interface/pages/chat/components/spaces/widgets/call_controls.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
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

  final _show = false.obs;

  Timer? timer;

  @override
  Widget build(BuildContext context) {

    SpacesController controller = Get.find();

    return Hero(
      tag: "call",
      child: Container(
        color: Get.theme.colorScheme.background,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  
                      //* Participants
                      Expanded(
                        flex: 3,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Padding(
                              padding: const EdgeInsets.all(defaultSpacing),
                              child: CallGridView(constraints: constraints),
                            );
                          }
                        ),
                      ),
                  
                      //* Controls
                      callControls(controller)
                  
                    ]
                  ),
                  
                  //* Overlay
                  Obx(() => 
                    Animate(
                      effects: const [
                        FadeEffect(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut
                        )
                      ],
                      target: _show.value ? 0.0 : 0.0, // TODO: Re-enable in the future
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
        
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget callControls(SpacesController controller) => Padding(
    padding: const EdgeInsets.all(defaultSpacing),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() =>
          LoadingIconButton(
            loading: false.obs,
            onTap: () {
              if(controller.playMode.value) {
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
                  } 
                ));
                return;
              }
              controller.fullScreen.toggle();
              if(controller.fullScreen.value) {
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
          onTap: () {},
          icon: Icons.settings,
          iconSize: 30,
        ),
      ],
    ),
  );
}