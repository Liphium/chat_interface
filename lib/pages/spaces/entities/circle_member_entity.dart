import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CircleMemberEntity extends StatefulWidget {
  final SpaceMember member;

  final double bottomPadding;
  final double rightPadding;

  const CircleMemberEntity({super.key, required this.bottomPadding, required this.rightPadding, required this.member});

  @override
  State<CircleMemberEntity> createState() => _MemberEntityState();
}

class _MemberEntityState extends State<CircleMemberEntity> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding, right: widget.rightPadding),
      child: Stack(
        children: [
          Obx(
            () => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.member.isSpeaking.value ? Colors.green : Colors.transparent,
                  width: 4,
                ),
              ),
              width: 100,
              height: 100,
              child: UserAvatar(
                id: widget.member.friend.id,
                size: 100,
              ),
            ),
          ),

          //* Muted indicator
          Obx(
            () => Visibility(
              visible: widget.member.isMuted.value,
              child: Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      BoxShadow(
                        color: Get.theme.colorScheme.primaryContainer,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Icon(
                      Icons.mic_off,
                      color: Get.theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ),

          //* Deafened indicator
          Obx(
            () => Visibility(
              visible: widget.member.isDeafened.value,
              child: Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      if (!widget.member.isMuted.value)
                        BoxShadow(
                          color: Get.theme.colorScheme.primaryContainer,
                          blurRadius: 10,
                        ),
                    ],
                  ),
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Icon(
                      Icons.volume_off,
                      color: Get.theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
