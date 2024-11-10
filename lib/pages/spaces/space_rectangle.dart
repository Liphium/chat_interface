import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/pages/spaces/widgets/space_controls.dart';
import 'package:chat_interface/pages/spaces/widgets/spaces_message_feed.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SpaceRectangle extends StatefulWidget {
  const SpaceRectangle({super.key});

  @override
  State<SpaceRectangle> createState() => _SpaceRectangleState();
}

class _SpaceRectangleState extends State<SpaceRectangle> {
  final controlsHovered = false.obs;
  final hovered = true.obs;
  Timer? timer;
  final GlobalKey tabletopKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "call",
      child: buildRectangle(Get.find()),
    );
  }

  Widget buildRectangle(SpacesController controller) {
    return Container(
      color: Get.theme.colorScheme.inverseSurface,
      child: LayoutBuilder(builder: (context, constraints) {
        return MouseRegion(
          onEnter: (event) {
            hovered.value = true;
          },
          onHover: (event) {
            hovered.value = true;
            if (timer != null) timer?.cancel();
            timer = Timer(1000.ms, () {
              hovered.value = false;
            });
          },
          onExit: (event) {
            hovered.value = false;
            timer?.cancel();
          },
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    const TabletopView(),

                    //* Controls
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(
                        () => Animate(
                          effects: [
                            FadeEffect(
                              duration: 150.ms,
                              end: 0.0,
                              begin: 1.0,
                            )
                          ],
                          target: hovered.value || controlsHovered.value ? 0 : 1,
                          child: Container(
                            width: double.infinity,
                            // Create a gradient on this container from bottom to top
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0),
                                ],
                              ),
                            ),

                            child: MouseRegion(
                              onEnter: (event) => controlsHovered.value = true,
                              onExit: (event) => controlsHovered.value = false,
                              child: SpaceControls(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // The chat sidebar
              Obx(
                () => Animate(
                  effects: [
                    ExpandEffect(
                      curve: Curves.easeInOut,
                      duration: 250.ms,
                      axis: Axis.horizontal,
                      alignment: Alignment.centerRight,
                    ),
                    FadeEffect(
                      duration: 250.ms,
                    )
                  ],
                  onInit: (ac) => ac.value = controller.chatOpen.value ? 1 : 0,
                  target: controller.chatOpen.value ? 1 : 0,
                  child: Container(
                    color: Get.theme.colorScheme.onInverseSurface,
                    width: 380,
                    child: SpacesMessageFeed(),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }
}
