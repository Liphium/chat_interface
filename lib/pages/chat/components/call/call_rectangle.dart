import 'dart:ui';

import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/pages/chat/components/call/call_grid.dart';
import 'package:chat_interface/pages/chat/components/call/call_scroll.dart';
import 'package:chat_interface/pages/chat/components/call/entities/circle_member_entity.dart';
import 'package:chat_interface/pages/chat/components/call/entities/rectangle_member_entity.dart';
import 'package:chat_interface/pages/chat/components/call/widgets/call_controls.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallRectangle extends StatefulWidget {

  const CallRectangle({super.key});

  @override
  State<CallRectangle> createState() => _CallRectangleState();
}

final regtangularCallMembers = true.obs;

class _CallRectangleState extends State<CallRectangle> {

  @override
  Widget build(BuildContext context) {

    CallController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          //* Participants
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.all(defaultSpacing),
                  child: Obx(() =>
                    !controller.expanded.value ? 
                    CallScrollView(constraints: constraints, cinema: regtangularCallMembers) :
                    !controller.cinema.value ?
                    CallGridView(constraints: constraints) :
                    Row(
                      children: getParticipants(regtangularCallMembers, theme, 0, 0, const BoxConstraints(
                        maxHeight: 100,
                      )),
                    )
                  ),
                );
              }
            ),
          ),

          //* Controls
          Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() =>
                  LoadingIconButton(
                    loading: false.obs,
                    onTap: () => controller.expanded.toggle(),
                    icon: !controller.expanded.value ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    iconSize: 35,
                  ),
                ),
                const CallControls(),
                Obx(() =>
                  LoadingIconButton(
                    loading: false.obs,
                    onTap: () => controller.hideOverlay.toggle(),
                    icon: controller.hideOverlay.value ? Icons.fullscreen_rounded : Icons.fullscreen_exit_rounded,
                    iconSize: 35,
                  ),
                ),
              ],
            ),
          )

        ]
      )
    );
  }
}

List<Widget> getParticipants(RxBool rectangular, ThemeData theme, double bottom, double right, BoxConstraints constraints, [int count = 5]) {
 
  return List.generate(count, (index) => 
    ConstrainedBox(
      constraints: constraints,
      child: Obx(() =>
        rectangular.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        CircleMemberEntity(bottomPadding: bottom, rightPadding: right,),
      ),
    ),
  );
}