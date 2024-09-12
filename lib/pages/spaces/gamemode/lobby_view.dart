import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/pages/spaces/entities/entity_renderer.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class LobbyView extends StatefulWidget {
  final GameSession session;

  const LobbyView({super.key, required this.session});

  @override
  State<LobbyView> createState() => _LobbyViewState();
}

class _LobbyViewState extends State<LobbyView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(sectionSpacing),
          child: Obx(() => widget.session.members.length >= widget.session.minPlayers
              ? Text(
                  "game.lobby".trParams({"count": widget.session.members.length.toString(), "max": widget.session.maxPlayers.toString()}),
                  style: Get.theme.textTheme.headlineMedium,
                )
              : Text(
                  "game.lobby_waiting".trParams({"count": widget.session.members.length.toString(), "min": widget.session.minPlayers.toString()}),
                  style: Get.theme.textTheme.headlineMedium,
                )),
        ),
        verticalSpacing(sectionSpacing),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(defaultSpacing),
            child: Obx(() => Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: renderCircleEntites(0, 0, widget.session.members),
                )),
          ),
        ),
        Obx(() => Animate(
              effects: [
                ExpandEffect(
                  duration: 250.ms,
                  axis: Axis.vertical,
                  alignment: Alignment.center,
                  curve: Curves.ease,
                ),
                ScaleEffect(
                  delay: 250.ms,
                  duration: 500.ms,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: scaleAnimationCurve,
                )
              ],
              target: widget.session.members.length >= widget.session.minPlayers ? 1.0 : 0.0,
              child: Padding(
                  padding: const EdgeInsets.all(sectionSpacing),
                  child: FJElevatedButton(
                    onTap: () => widget.session.start(),
                    secondary: true,
                    child: Padding(
                      padding: const EdgeInsets.all(elementSpacing),
                      child: Text("game.start".tr, style: Get.theme.textTheme.titleLarge),
                    ),
                  )),
            ))
      ],
    );
  }
}
