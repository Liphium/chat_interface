import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class RectangleMemberEntity extends StatefulWidget {
  final SpaceMember member;

  const RectangleMemberEntity({super.key, required this.member});

  @override
  State<RectangleMemberEntity> createState() => _RectangleMemberEntityState();
}

class _RectangleMemberEntityState extends State<RectangleMemberEntity> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Obx(
          () {
            Widget mainWidget;
            if (widget.member.isVideo.value && widget.member.participant.value!.videoTrackPublications.firstOrNull?.track != null) {
              mainWidget = VideoTrackRenderer(
                widget.member.participant.value!.videoTrackPublications.first.track! as VideoTrack,
              );
            } else {
              mainWidget = Container(
                color: Get.theme.colorScheme.primaryContainer,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: UserAvatar(
                        size: constraints.maxWidth * 0.3,
                        id: widget.member.friend.id,
                      ),
                    );
                  },
                ),
              );
            }

            return Stack(
              children: [
                //* Main widget
                mainWidget,

                //* Talking indicator
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      border: Border.all(
                        color: widget.member.isSpeaking.value ? Colors.green : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                ),

                //* Muted indicator
                Obx(
                  () => Visibility(
                    visible: widget.member.isMuted.value,
                    child: Positioned(
                      right: elementSpacing,
                      bottom: elementSpacing,
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
                      right: elementSpacing,
                      bottom: elementSpacing,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
