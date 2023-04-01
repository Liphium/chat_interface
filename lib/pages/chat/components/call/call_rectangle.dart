import 'package:chat_interface/controller/chat/conversation/call_controller.dart';
import 'package:chat_interface/pages/chat/components/call/call_member.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallRectangle extends StatefulWidget {
  const CallRectangle({super.key});

  @override
  State<CallRectangle> createState() => _CallRectangleState();
}

class _CallRectangleState extends State<CallRectangle> {
  @override
  Widget build(BuildContext context) {

    final controller = Get.find<CallController>();

    return Material(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing * 2),
          child: Obx(() => 
            Row(
              children: controller.friends.map((element) {

                final participant = controller.participants[element.id]!;
                return CallMember(participant: participant, friend: element);
              }).toList(),
            )
          )
        )
      )
    );
  }
}