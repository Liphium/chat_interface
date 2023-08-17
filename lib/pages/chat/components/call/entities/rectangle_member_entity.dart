import 'package:chat_interface/controller/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/conversation/call/call_member_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RectangleMemberEntity extends StatefulWidget {

  final Member member;

  final double bottomPadding;
  final double rightPadding;

  const RectangleMemberEntity({super.key, this.bottomPadding = 0, this.rightPadding = 0, required this.member});

  @override
  State<RectangleMemberEntity> createState() => _RectangleMemberEntityState();
}

class _RectangleMemberEntityState extends State<RectangleMemberEntity> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding, right: widget.rightPadding),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          color: theme.colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(defaultSpacing),
          child: InkWell(
            borderRadius: BorderRadius.circular(defaultSpacing),
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              Get.find<CallController>().cinema.toggle();
            },
            child: Obx(() => 
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  border: widget.member.isSpeaking.value ? Border.all(color: Colors.green, width: 2) : null,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultSpacing),
                    child: Text(widget.member.friend.name, style: theme.textTheme.titleLarge)
                  )
                ),
              ),
            )
          ),
        ),
      ),
    );
  }
}