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

class _CallRectangleState extends State<CallRectangle> {

  final gridView = true.obs;
  final cinema = true.obs;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.black,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          //* Participants
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Obx(() =>
                gridView.value ?
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.center,
                    direction: Axis.horizontal,
                    spacing: defaultSpacing,
                    runSpacing: defaultSpacing,
                    children: getParticipants(theme, 0, 0),
                  ),
                ) :
                Row(
                  children: getParticipants(theme, 0, 0),
                )
              ),
            ),
          ),

          //* Controls
          Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LoadingIconButton(
                  loading: false.obs,
                  onTap: () => cinema.toggle(),
                  icon: Icons.arrow_downward,
                  iconSize: 35,
                ),
                const CallControls(),
                LoadingIconButton(
                  loading: false.obs,
                  onTap: () => {},
                  icon: Icons.fullscreen,
                  iconSize: 35,
                )
              ],
            ),
          )

        ]
      )
    );
  }

  List<Widget> getParticipants(ThemeData theme, double bottom, double right) {
    return [
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
      Obx(() =>
        cinema.value ?
        RectangleMemberEntity(bottomPadding: bottom, rightPadding: right,) :
        const CircleMemberEntity(),
      ),
    ];
  }
}