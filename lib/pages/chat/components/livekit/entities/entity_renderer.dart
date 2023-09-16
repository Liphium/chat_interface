import 'package:chat_interface/controller/conversation/livekit/call_controller.dart';
import 'package:chat_interface/controller/conversation/livekit/call_member_controller.dart';
import 'package:chat_interface/controller/conversation/livekit/output_controller.dart';
import 'package:chat_interface/pages/chat/components/livekit/entities/circle_member_entity.dart';
import 'package:chat_interface/pages/chat/components/livekit/entities/rectangle_member_entity.dart';
import 'package:chat_interface/pages/chat/components/livekit/entities/video_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@Deprecated("LiveKit is no longer supported (will be used when we tackle the video call feature)")
List<Widget> renderEntites(double bottom, double right, BoxConstraints constraints, [int maxHero = 17]) {

  CallController controller = Get.find();
  PublicationController publicationController = Get.find();
  CallMemberController memberController = Get.find();

  final entities = <Widget>[];

  for(var member in memberController.members.values) {

    //* Add member renderer
    Widget memberRenderer = ConstrainedBox(
      constraints: constraints,
      child: !controller.hasVideo.value ?
      CircleMemberEntity(
        member: member,
        bottomPadding: bottom,
        rightPadding: right,
      ) :
      RectangleMemberEntity(
        member: member,
        bottomPadding: bottom,
        rightPadding: right,
      ),
    );

    // Add to list
    entities.add(      
      entities.length > maxHero ?
      memberRenderer :
      Hero(
        tag: "mem${member.friend.id}",
        child: memberRenderer,
      )
    );

    //* Add screenshare
    if(publicationController.screenshares[member.friend.id] != null) {

      // Add to list
      entities.add(
        entities.length > maxHero ?
        ConstrainedBox(constraints: constraints, child: VideoEntity(video: publicationController.screenshares[member.friend.id]!)) :
        Hero(
          tag: "ss${member.friend.id}",
          child: ConstrainedBox(constraints: constraints, child: VideoEntity(video: publicationController.screenshares[member.friend.id]!)),
        )
      );
    }
  }

  return entities;
}