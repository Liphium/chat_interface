import 'package:chat_interface/controller/chat/conversation/call/call_member_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircleMemberEntity extends StatefulWidget {

  final Member member;

  final double bottomPadding;
  final double rightPadding;

  const CircleMemberEntity({super.key, required this.bottomPadding, required this.rightPadding, required this.member});

  @override
  State<CircleMemberEntity> createState() => _MemberEntityState();
}

class _MemberEntityState extends State<CircleMemberEntity> {
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding, right: widget.rightPadding),
      child: Stack(
        children: [
          Obx(() =>
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(200),
                border: widget.member.isSpeaking.value ? Border.all(color: Colors.green, width: 2) : null,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(defaultSpacing),
                  child: Text(widget.member.friend.name, style: theme.textTheme.bodyLarge!.copyWith(fontSize: 17), overflow: TextOverflow.ellipsis,)
                )
              )
            )
          ),
    
          //* Muted indicator
          Obx(() =>
            Visibility(
              visible: widget.member.isMuted.value,
              child: Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  width: 30,
                  height: 30,
                  child: const Center(
                    child: Icon(
                      Icons.mic_off,
                      color: Colors.white,
                    )
                  )
                ),
              ),
            ),
          ),
    
          //* Speaker indicator
          Obx(() =>
            Visibility(
              visible: widget.member.isAudioMuted.value,
              child: Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(200),
                  ),
                  width: 30,
                  height: 30,
                  child: const Center(
                    child: Icon(
                      Icons.volume_off,
                      color: Colors.white,
                    )
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}