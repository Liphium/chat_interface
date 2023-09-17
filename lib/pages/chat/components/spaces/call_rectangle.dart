import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/chat_page.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_grid.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_page.dart';
import 'package:chat_interface/pages/chat/components/spaces/widgets/call_controls.dart';
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
              controller.fullScreen.toggle();
              if(controller.fullScreen.value) {
                Get.offAll(const CallPage(), transition: Transition.fadeIn);
              } else {
                Get.offAll(const ChatPage(), transition: Transition.fadeIn);
              }
            },
            icon: controller.fullScreen.value ? Icons.arrow_forward : Icons.arrow_back_rounded,
            iconSize: 35,
          ),
        ),

        const CallControls(),

        LoadingIconButton(
          loading: false.obs,
          onTap: () {},
          icon: Icons.forum,
          iconSize: 35,
        ),
      ],
    ),
  );
}