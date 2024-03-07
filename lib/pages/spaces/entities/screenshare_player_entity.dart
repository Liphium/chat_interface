import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class ScreensharePlayerEntity extends StatefulWidget {
  final TrackPublication<VideoTrack> publication;

  const ScreensharePlayerEntity({super.key, required this.publication});

  @override
  State<ScreensharePlayerEntity> createState() => _RectangleMemberEntityState();
}

class _RectangleMemberEntityState extends State<ScreensharePlayerEntity> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          color: Get.theme.colorScheme.primaryContainer,
          child: InkWell(
            onTap: () => Get.find<SpacesController>().cinemaMode(widget),
            hoverColor: Colors.transparent,
            child: Obx(
              () {
                if (widget.publication.track == null) {
                  return Container();
                }

                return VideoTrackRenderer(widget.publication.track!);
              },
            ),
          ),
        ),
      ),
    );
  }
}
