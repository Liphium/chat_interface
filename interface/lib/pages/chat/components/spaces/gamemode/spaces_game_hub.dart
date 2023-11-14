import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_rectangle.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SpacesGameHub extends StatefulWidget {
  const SpacesGameHub({super.key});

  @override
  State<SpacesGameHub> createState() => _SpacesGameHubState();
}

class _SpacesGameHubState extends State<SpacesGameHub> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    final gameController = Get.find<GameHubController>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Animate(
                effects: [
                  ExpandEffect(
                    delay: 500.ms,
                    duration: 500.ms,
                    curve: const ElasticOutCurve(0.6),
                    axis: Axis.horizontal,
                  )
                ],
                target: 1.0,
                child: Container(
                  color: Get.theme.colorScheme.onBackground,
                  width: min(max(constraints.maxWidth / 4, 350), 450),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: sectionSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalSpacing(sectionSpacing),
                        Text("Playing".tr, style: Get.textTheme.headlineMedium),
              
                        verticalSpacing(sectionSpacing * 2),
                        Text("Games".tr, style: Get.textTheme.headlineMedium),

                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: gameController.games.length,
                          itemBuilder: (context, index) {
                            final game = gameController.games[index];

                            return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: defaultSpacing),
                                child: InkWell(
                                  onTap: () => {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: AssetImage(game.coverImageAsset),
                                        fit: BoxFit.cover
                                      )
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(defaultSpacing),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(game.name, style: Get.textTheme.labelLarge),
                                          verticalSpacing(defaultSpacing / 2),
                                          Text(game.description, style: Get.textTheme.bodyMedium),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            );
                          },
                        )
                      ],
                    ),
                  )
                ),
              ),
              Expanded(
                child: CallRectangle()
              ),
            ],
          );
        }
      ),
    );
  }
}