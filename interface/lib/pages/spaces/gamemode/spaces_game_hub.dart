import 'dart:math';

import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/call_rectangle.dart';
import 'package:chat_interface/pages/spaces/widgets/call_controls.dart';
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
    final memberController = Get.find<SpaceMemberController>();
    final gameController = Get.find<GameHubController>();
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
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
                onInit: (controller) {
                  if(gameController.engine.value != null) {
                    controller.value = 1.0;
                  }
                },
                target: 1.0,
                child: Container(
                  color: Get.theme.colorScheme.onBackground,
                  width: min(max(constraints.maxWidth / 4, 350), 420),
                  height: constraints.maxHeight,
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
                              
                              Obx(() => 
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: gameController.sessions.length,
                                  itemBuilder: (context, index) {
                                    final session = gameController.sessions.values.elementAt(index);
                                    final game = gameController.games[session.game]!;
                            
                                    return Padding(
                                      padding: const EdgeInsets.only(top: sectionSpacing),
                                      child: Obx(() {
                                        final selected = gameController.engine.value?.sessionId == session.id;
                                        return Material(
                                          borderRadius: BorderRadius.circular(sectionSpacing),
                                          color: selected ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(sectionSpacing),
                                            onTap: () => {},
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(sectionSpacing),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Obx(() {
                                        
                                                        final int max = min(session.members.length, 5);
                                                        return Row(
                                                          children: List.generate(max, (index) {
                                                            final member = memberController.members[session.members[index]];
                                                            return Padding(
                                                              padding: const EdgeInsets.only(right: elementSpacing),
                                                              child: Tooltip(
                                                                message: member?.friend.name ?? "Unknown",
                                                                child: SizedBox(
                                                                  width: 40,
                                                                  height: 40,
                                                                  child: CircleAvatar(
                                                                    backgroundColor: selected ? Get.theme.colorScheme.onBackground : index % 2 == 0 ? Get.theme.colorScheme.primary : Get.theme.colorScheme.tertiaryContainer,
                                                                    child: Icon(Icons.person, size: 23, color: Get.theme.colorScheme.onSurface),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        );
                                                      }),
                                                      verticalSpacing(defaultSpacing),
                                                      Text(game.name, style: Get.textTheme.titleMedium),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                    );
                                  },
                                )
                              ),

                              verticalSpacing(sectionSpacing * 2),
                              Text("Games".tr, style: Get.textTheme.headlineMedium),
                          
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: gameController.games.length,
                                itemBuilder: (context, index) {
                                  final game = gameController.games.values.elementAt(index);
                          
                                  return Padding(
                                    padding: const EdgeInsets.only(top: sectionSpacing),
                                    child: InkWell(
                                      onTap: () {
                                        if(gameController.sessionLoading.value) {
                                          return;
                                        }
                                        gameController.newSession(game.serverId);
                                      },
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
              Expanded(
                child: Obx(() {
                  if(gameController.engine.value != null) {
                    return Column(
                      children: [
                        Expanded(
                          child: Obx(() => gameController.engine.value!.render(context))
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              color: Get.theme.colorScheme.background,
                              padding: const EdgeInsets.all(defaultSpacing),
                              width: constraints.maxWidth,
                              child: const Center(
                                child: CallControls()
                              )
                            );
                          }
                        )
                      ],
                    );
                  }

                  return const CallRectangle();
                }),
              ),
            ],
          );
        }
      ),
    );
  }
}