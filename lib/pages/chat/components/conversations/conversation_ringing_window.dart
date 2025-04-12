import 'dart:math';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/spaces/ringing_manager.dart';
import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ConversationRingingWindow extends StatefulWidget {
  final Conversation conversation;
  final SpaceConnectionContainer container;

  const ConversationRingingWindow({super.key, required this.conversation, required this.container});

  @override
  State<ConversationRingingWindow> createState() => ConversationRingingWindowState();
}

class ConversationRingingWindowState extends State<ConversationRingingWindow> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Animate(
        effects: [ScaleEffect(duration: 250.ms, curve: Curves.ease)],
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: BoxDecoration(color: Get.theme.colorScheme.onInverseSurface, borderRadius: BorderRadius.circular(sectionSpacing)),
              padding: const EdgeInsets.all(dialogPadding),
              width: min(constraints.maxWidth * 0.9, 350),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Animate(
                    effects: [ShakeEffect(delay: 1000.ms, rotation: 0.1, duration: 500.ms)],
                    onInit: (controller) {
                      controller.forward(from: 0);
                    },
                    onComplete: (controller) {
                      controller.forward(from: 0);
                    },
                    child: Icon(Icons.call, color: Get.theme.colorScheme.onPrimary, size: 55),
                  ),
                  verticalSpacing(elementSpacing),
                  Text(
                    widget.conversation.isGroup ? widget.conversation.container.name : widget.conversation.dmName,
                    style: Get.textTheme.headlineMedium,
                    textHeightBehavior: noTextHeight,
                  ),
                  verticalSpacing(elementSpacing),
                  Text("spaces.calling".tr, style: Get.textTheme.bodyLarge, textHeightBehavior: noTextHeight),
                  verticalSpacing(sectionSpacing),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.done, size: 30),
                        onPressed: () {
                          Get.back();
                          RingingManager.stopRingtone();
                          SpaceController.join(widget.container);
                        },
                        color: Get.theme.colorScheme.secondary,
                      ),
                      horizontalSpacing(defaultSpacing),
                      IconButton(
                        icon: const Icon(Icons.close, size: 30),
                        onPressed: () {
                          RingingManager.stopRingtone();
                          Get.back();
                        },
                        color: Get.theme.colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
