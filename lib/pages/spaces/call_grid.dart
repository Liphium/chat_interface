import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/entities/entity_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
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
      if (spaceMemberController.membersLoading.value || spaceMemberController.members.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary),
        );
      }

      int people = spaceMemberController.members.length;
      if (people == 0) {
        return const Center(
          child: Text("No one is here"),
        );
      }

      // Calculate the available height for every participant
      double computedHeight = _calculateSmallRectangleHeight(Size(widget.constraints.maxWidth, widget.constraints.maxHeight), people);
      computedHeight -= defaultSpacing * people;

      if (computedHeight > _minHeight * 0.4 || !controller.hasVideo.value) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            direction: Axis.horizontal,
            spacing: defaultSpacing * 1.5,
            runSpacing: defaultSpacing * 1.5,
            children: renderEntites(
              0,
              0,
              BoxConstraints(
                maxHeight: max(_minHeight, computedHeight),
              ),
            ),
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
                  children: renderEntites(
                    0,
                    0,
                    BoxConstraints(
                      maxHeight: max(_minHeight, computedHeight),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  double _calculateSmallRectangleHeight(Size parentSize, int n) {
    // Do it for the height
    double idealHeight = parentSize.height;
    double childrenWidth = parentSize.height * (16.0 / 9.0);
    int numFit = 0;
    while (idealHeight * (n - numFit) > parentSize.height) {
      idealHeight -= 1;
      childrenWidth = idealHeight * (16.0 / 9.0);
      numFit = (parentSize.width ~/ childrenWidth).ceil() - 1;
    }

    sendLog("Ideal height: $idealHeight");

    return idealHeight;
  }
}
