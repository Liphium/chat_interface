import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/entities/circle_member_entity.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

List<Widget> renderEntites(double bottom, double right, BoxConstraints constraints, {int maxHero = 17, List<String>? toRender, Axis? axis}) {
  toRender ??= SpaceMemberController.members.value.keys.toList();

  final entities = <Widget>[];

  for (int i = 0; i < toRender.length; i++) {
    //* Add member renderer
    Widget memberRenderer = ConstrainedBox(
      constraints: constraints,
      child: CircleMemberEntity(
        member: SpaceMemberController.members.value[toRender[i]]!,
        bottomPadding: bottom,
        rightPadding: right,
      ),
    );

    // Add to list
    if (axis != null) {
      final spacing = i == 0 ? 0.0 : defaultSpacing;
      entities.add(
        Padding(
          padding: axis == Axis.vertical ? EdgeInsets.only(top: spacing) : EdgeInsets.only(left: spacing),
          child: memberRenderer,
        ),
      );
    } else {
      entities.add(memberRenderer);
    }
  }

  return entities;
}

List<Widget> renderCircleEntites(double bottom, double right, [List<String>? toRender]) {
  toRender ??= SpaceMemberController.members.value.keys.toList();
  final entities = <Widget>[];

  for (int i = 0; i < toRender.length; i++) {
    // Add to list
    entities.add(CircleMemberEntity(
      member: SpaceMemberController.members.value[toRender[i]]!,
      bottomPadding: bottom,
      rightPadding: right,
    ));
  }

  return entities;
}
