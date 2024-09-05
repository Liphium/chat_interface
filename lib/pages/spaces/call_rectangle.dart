import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/spaces/call_cinema.dart';
import 'package:chat_interface/pages/spaces/call_grid.dart';
import 'package:chat_interface/pages/spaces/call_page.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/pages/spaces/widgets/call_controls.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class CallRectangle extends StatefulWidget {
  const CallRectangle({super.key});

  @override
  State<CallRectangle> createState() => _CallRectangleState();
}

class _CallRectangleState extends State<CallRectangle> {
  final controlsHovered = false.obs;
  final hovered = true.obs;
  Timer? timer;
  final GlobalKey tabletopKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "call",
      flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) => buildRectangle(Get.find(), cache: true),
      child: buildRectangle(Get.find()),
    );
  }

  Widget buildRectangle(SpacesController controller, {cache = false}) {
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
          child: Stack(
            children: [
              Obx(
                () {
                  if (controller.currentTab.value == SpaceTabType.table.index) {
                    return const TabletopView();
                  }

                  if (controller.currentTab.value == SpaceTabType.cinema.index && controller.cinemaWidget.value != null) {
                    return const CallCinemaView();
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: CallGridView(constraints: constraints),
                      );
                    },
                  );
                },
              ),

              //* Tab selector
              Align(
                alignment: Alignment.topCenter,
                child: Obx(
                  () => Animate(
                    effects: [
                      FadeEffect(
                        duration: 150.ms,
                        end: 0.0,
                        begin: 1.0,
                      )
                    ],
                    target: (hovered.value || controlsHovered.value) || controller.currentTab.value == SpaceTabType.table.index ? 0 : 1,
                    child: Container(
                      width: double.infinity,
                      // Create a gradient on this container from bottom to top
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: sectionSpacing),
                        child: Center(
                          heightFactor: 1,
                          child: LPHTabElement(
                            selected: Get.find<SpacesController>().currentTab,
                            tabs: SpaceTabType.values.map((t) => t.name.tr).toList(),
                            onTabSwitch: (tab) {
                              // Get the type
                              SpaceTabType? type;
                              for (var t in SpaceTabType.values) {
                                if (t.name.tr == tab) {
                                  type = t;
                                  break;
                                }
                              }

                              // Switch to the new tab
                              if (type != null) {
                                Get.find<SpacesController>().switchToTab(type);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

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
                        child: buildControls(controller),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildControls(SpacesController controller) {
    return Center(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.only(
          right: sectionSpacing,
          left: sectionSpacing,
          bottom: sectionSpacing,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => LoadingIconButton(
                background: true,
                loading: false.obs,
                onTap: () {
                  controller.hideSidebar.toggle();
                  if (controller.hideSidebar.value) {
                    Get.offAll(const CallPage(), transition: Transition.fadeIn);
                  } else {
                    Get.offAll(const ChatPageDesktop(), transition: Transition.fadeIn);
                  }
                },
                icon: controller.hideSidebar.value ? Icons.arrow_forward : Icons.arrow_back,
                iconSize: 30,
              ),
            ),
            const Spacer(),
            const CallControls(),
            const Spacer(),
            Obx(
              () {
                return LoadingIconButton(
                  loading: false.obs,
                  background: true,
                  onTap: () => controller.toggleFullScreen(),
                  icon: controller.fullScreen.value ? Icons.fullscreen_exit : Icons.fullscreen,
                  iconSize: 30,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
