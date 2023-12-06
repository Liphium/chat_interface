import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/entities/entity_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallGridView extends StatefulWidget {

  final BoxConstraints constraints;
  final RxList<String>? filter;

  const CallGridView({super.key, required this.constraints, this.filter});

  @override
  State<CallGridView> createState() => _CallGridViewState();
}

class _CallGridViewState extends State<CallGridView> {

  final double _minHeight = 120;

  @override
  Widget build(BuildContext context) {
    SpacesController controller = Get.find();
    SpaceMemberController spaceMemberController = Get.find();

    return Obx(() {

      if(spaceMemberController.membersLoading.value || spaceMemberController.members.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary),
        );
      }

      int people = spaceMemberController.members.length;
      if(people == 0) {
        return const Center(
          child: Text("No one is here"),
        );
      }

      // Calculate the available height for every participant
      double computedHeight = _calculateSmallRectangleHeight(widget.constraints.maxWidth, widget.constraints.maxHeight, people);
      computedHeight -= defaultSpacing * people;

      if (computedHeight > _minHeight*0.4 || !controller.hasVideo.value) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.horizontal,
            spacing: defaultSpacing * 1.5,
            runSpacing: defaultSpacing * 1.5,
          
            children: renderEntites(0, 0, BoxConstraints(
              maxHeight: max(_minHeight, computedHeight),
            )),
          ),
        );
      } else {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  spacing: defaultSpacing * 1.5,
                  runSpacing: defaultSpacing * 1.5,
                
                  children: renderEntites(0, 0, BoxConstraints(
                    maxHeight: max(_minHeight, computedHeight),
                  )),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  // Thanks Bing Chat (you solved a problem I worked on for 2 hours)
  double _calculateSmallRectangleHeight(double bigRectangleWidth, double bigRectangleHeight, int n) {
    double aspectRatio = 16 / 9;
    int columns = sqrt(n).ceil();
    int rows = (n / columns).ceil();
    double smallRectangleWidth = bigRectangleWidth / columns;
    double smallRectangleHeight = smallRectangleWidth / aspectRatio;

    if (smallRectangleHeight * rows > bigRectangleHeight) {
      smallRectangleHeight = bigRectangleHeight / rows;
      smallRectangleWidth = smallRectangleHeight * aspectRatio;
    }

    return smallRectangleHeight;
  }
}