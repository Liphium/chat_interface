import 'package:chat_interface/controller/chat/conversation/call/call_member_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberEntity extends StatefulWidget {

  final Member member;

  const MemberEntity({super.key, required this.member});

  @override
  State<MemberEntity> createState() => _MemberEntityState();
}

class _MemberEntityState extends State<MemberEntity> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    StatusController controller = Get.find();

    return Obx(() => Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(200),
        border: Border.all(
          color: widget.member.isSpeaking.value ? Colors.green : Colors.transparent,
          width: 2
        )
      ),
      width: 100,
      height: 100,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Text(
            widget.member.friend.id == controller.id.value ? controller.name.value : widget.member.friend.name,
            style: theme.textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        )
      )
    ));
  }
}