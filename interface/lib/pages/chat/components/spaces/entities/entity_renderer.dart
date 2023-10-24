import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/chat/components/spaces/entities/circle_member_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<Widget> renderEntites(double bottom, double right, BoxConstraints constraints, [int maxHero = 17]) {

  SpaceMemberController memberController = Get.find();

  final entities = <Widget>[];

  for(var member in memberController.members.values) {

    //* Add member renderer
    Widget memberRenderer = ConstrainedBox(
      constraints: constraints,
      child: CircleMemberEntity(
        member: member,
        bottomPadding: bottom,
        rightPadding: right,
      )
    );

    // Add to list
    entities.add(      
      entities.length > maxHero ?
      memberRenderer :
      memberRenderer
    );
  }

  return entities;
}