import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/entities/circle_member_entity.dart';
import 'package:chat_interface/pages/spaces/entities/rectangle_member_entity.dart';
import 'package:chat_interface/pages/spaces/entities/screenshare_player_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

List<Widget> renderEntites(double bottom, double right, BoxConstraints constraints, [int maxHero = 17, List<String>? toRender]) {
  SpacesController controller = Get.find();
  SpaceMemberController memberController = Get.find();
  toRender ??= memberController.members.keys.toList();

  final entities = <Widget>[];

  for (int i = 0; i < toRender.length; i++) {
    //* Add member renderer
    Widget memberRenderer = controller.hasVideo.value || memberController.members.length > 1
        ? ConstrainedBox(
            constraints: constraints,
            child: RectangleMemberEntity(
              member: memberController.members[toRender[i]]!,
            ),
          )
        : ConstrainedBox(
            constraints: constraints,
            child: CircleMemberEntity(
              member: memberController.members[toRender[i]]!,
              bottomPadding: bottom,
              rightPadding: right,
            ),
          );

    if (memberController.members[toRender[i]]!.participant.value != null) {
      if (memberController.members[toRender[i]]!.participant.value!.isScreenShareEnabled()) {
        entities.add(
          ScreensharePlayerEntity(
            publication: memberController.members[toRender[i]]!.participant.value!.getTrackPublicationBySource(TrackSource.screenShareVideo)! as TrackPublication<VideoTrack>,
          ),
        );
      }
    }

    // Add to list
    entities.add(entities.length > maxHero ? memberRenderer : memberRenderer);
  }

  return entities;
}

List<Widget> renderCircleEntites(double bottom, double right, [List<String>? toRender]) {
  SpaceMemberController memberController = Get.find();
  toRender ??= memberController.members.keys.toList();
  final entities = <Widget>[];

  for (int i = 0; i < toRender.length; i++) {
    // Add to list
    entities.add(CircleMemberEntity(
      member: memberController.members[toRender[i]]!,
      bottomPadding: bottom,
      rightPadding: right,
    ));
  }

  return entities;
}
