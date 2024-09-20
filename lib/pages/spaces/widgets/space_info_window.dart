import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceInfoWindow extends StatelessWidget {
  const SpaceInfoWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    final memberController = Get.find<SpaceMemberController>();

    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Space #${controller.id.value}", style: Get.theme.textTheme.titleMedium),
          ),
          Text("Status: ${SpacesController.livekitRoom!.engine.connectionState.name}"),
          verticalSpacing(defaultSpacing),
          Text("Members", style: Get.theme.textTheme.labelMedium),
          verticalSpacing(elementSpacing),
          Obx(
            () {
              return Column(
                children: memberController.members.values.map((member) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: elementSpacing),
                    child: Row(
                      children: [
                        Text(member.friend.displayName.value, style: Get.theme.textTheme.bodyMedium),
                        horizontalSpacing(defaultSpacing),
                        Text("#${member.id}", style: Get.theme.textTheme.bodyMedium),
                        horizontalSpacing(defaultSpacing),
                        Text("tracks: ${member.participant.value!.trackPublications.length}")
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          verticalSpacing(elementSpacing),
          Text("Publications", style: Get.theme.textTheme.labelMedium),
          verticalSpacing(elementSpacing),
          Column(
            children: SpacesController.livekitRoom!.localParticipant!.audioTrackPublications.map((track) {
              return Padding(
                padding: const EdgeInsets.only(bottom: elementSpacing),
                child: Row(
                  children: [
                    Text(track.name, style: Get.theme.textTheme.bodyMedium),
                    horizontalSpacing(defaultSpacing),
                    Text("${track.muted}", style: Get.theme.textTheme.bodyMedium),
                    horizontalSpacing(defaultSpacing),
                    Text("rate: ${(track.track!.currentBitrate as double).toStringAsFixed(2)}", style: Get.theme.textTheme.bodyMedium),
                    horizontalSpacing(defaultSpacing),
                    Text(track.sid, style: Get.theme.textTheme.bodyMedium),
                  ],
                ),
              );
            }).toList(),
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.refresh,
            label: "Resubscribe",
            onTap: () {
              SpacesController.livekitRoom!.remoteParticipants.forEach((identity, participant) {
                if (participant.audioTrackPublications.isEmpty) {
                  sendLog("no audio pub");
                }

                for (var track in participant.audioTrackPublications) {
                  if (!track.subscribed) {
                    sendLog("wasn't subscribed");
                  }
                  track.subscribe();
                }
              });
            },
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.public,
            label: "Republish",
            onTap: () async {
              await SpacesController.livekitRoom!.localParticipant!.rePublishAllTracks();
            },
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.public_off,
            label: "Unpublish mic",
            onTap: () async {
              await SpacesController.livekitRoom!.localParticipant!.unpublishAllTracks();
              sendLog(SpacesController.livekitRoom!.localParticipant!.audioTrackPublications.length);
            },
            loading: false.obs,
          ),
        ],
      ),
    );
  }
}
