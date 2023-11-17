import 'dart:math';
import 'dart:ui';

import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_rectangle.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';

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
                  child: DynMouseScroll(
                    scrollSpeed: 0.3,
                    builder: (context, controller, physics) {
                      return SingleChildScrollView(
                        controller: controller,
                        physics: physics,
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
                          
                                  return Padding(
                                    padding: const EdgeInsets.only(top: sectionSpacing),
                                    child: InkWell(
                                      onTap: () => {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(sectionSpacing),
                                          color: Get.theme.colorScheme.primaryContainer,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(sectionSpacing),
                                              child: AspectRatio(
                                                aspectRatio: 16 / 6,
                                                child: Image.asset(
                                                  game.coverImageAsset, fit: BoxFit.cover
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(sectionSpacing),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(game.name, style: Get.textTheme.titleMedium),
                                                  verticalSpacing(elementSpacing),
                                                  Text(game.description, overflow: TextOverflow.ellipsis, style: Get.textTheme.bodyMedium),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              verticalSpacing(sectionSpacing)
                            ],
                          ),
                        ),
                      );
                    }
                  )
                ),
              ),
              const Expanded(
                child: CallRectangle()
              ),
            ],
          );
        }
      ),
    );
  }
}