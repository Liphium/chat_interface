import 'dart:async';

import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/pages/spaces/widgets/space_controls.dart';
import 'package:chat_interface/pages/spaces/widgets/space_info_tab.dart';
import 'package:chat_interface/pages/spaces/widgets/space_members_tab.dart';
import 'package:chat_interface/pages/spaces/widgets/spaces_message_feed.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SpaceRectangle extends StatefulWidget {
  const SpaceRectangle({super.key});

  @override
  State<SpaceRectangle> createState() => _SpaceRectangleState();
}

class _SpaceRectangleState extends State<SpaceRectangle> {
  final _controlsHovered = signal(true);
  final _hovered = signal(true);
  Timer? _timer;

  // Space tabs
  final _tabs = [
    const SpaceInfoTab(),
    const TabletopView(),
  ];

  // Sidebar tabs
  final _sidebarTabs = [
    const SpacesMessageFeed(),
    const SpaceMembersTab(),
  ];

  @override
  void dispose() {
    _controlsHovered.dispose();
    _hovered.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "call",
      child: buildRectangle(),
    );
  }

  Widget buildRectangle() {
    return Container(
      color: Get.theme.colorScheme.inverseSurface,
      child: LayoutBuilder(builder: (context, constraints) {
        return MouseRegion(
          onEnter: (event) {
            _hovered.value = true;
          },
          onHover: (event) {
            _hovered.value = true;
            if (_timer != null) _timer?.cancel();
            _timer = Timer(1000.ms, () {
              _hovered.value = false;
            });
          },
          onExit: (event) {
            _hovered.value = false;
            _timer?.cancel();
          },
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Watch((context) {
                      return _tabs[SpaceController.currentTab.value];
                    }),

                    //* Tab
                    Align(
                      alignment: Alignment.topCenter,
                      child: Watch(
                        (context) => Animate(
                          effects: [
                            FadeEffect(
                              duration: 150.ms,
                              end: 0.0,
                              begin: 1.0,
                            )
                          ],
                          target: _hovered.value || _controlsHovered.value ? 0 : 1,
                          child: Container(
                            width: double.infinity,
                            // Create a gradient on this container from bottom to top
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(0),
                                  Colors.black.withAlpha(70),
                                ],
                              ),
                            ),

                            child: MouseRegion(
                              onEnter: (event) => _controlsHovered.value = true,
                              onExit: (event) => _controlsHovered.value = false,
                              child: Center(
                                heightFactor: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: sectionSpacing),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Get.theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(defaultSpacing),
                                    ),
                                    padding: EdgeInsets.all(elementSpacing),
                                    child: LPHTabElement(
                                      tabs: SpaceTabType.values.map((e) => e.name.tr).toList(),
                                      onTabSwitch: (el) {
                                        final type = SpaceTabType.values.firstWhereOrNull((t) => t.name.tr == el);
                                        if (type == null) {
                                          return;
                                        }
                                        SpaceController.switchToTabAndChange(type);
                                      },
                                      selected: SpaceController.currentTab,
                                    ),
                                  ),
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
                      child: Watch(
                        (context) => Animate(
                          effects: [
                            FadeEffect(
                              duration: 150.ms,
                              end: 0.0,
                              begin: 1.0,
                            )
                          ],
                          target: _hovered.value || _controlsHovered.value ? 0 : 1,
                          child: Container(
                            width: double.infinity,
                            // Create a gradient on this container from bottom to top
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(70),
                                  Colors.black.withAlpha(0),
                                ],
                              ),
                            ),

                            child: MouseRegion(
                              onEnter: (event) => _controlsHovered.value = true,
                              onExit: (event) => _controlsHovered.value = false,
                              child: SpaceControls(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // The Space sidebar
              Watch(
                (context) => Animate(
                  effects: [
                    ExpandEffect(
                      curve: Curves.easeInOut,
                      duration: 250.ms,
                      axis: Axis.horizontal,
                      alignment: Alignment.centerLeft,
                    ),
                    FadeEffect(
                      duration: 250.ms,
                    ),
                  ],
                  onInit: (ac) => ac.value = SpaceController.chatOpen.value ? 1 : 0,
                  target: SpaceController.chatOpen.value ? 1 : 0,
                  child: Container(
                    color: Get.theme.colorScheme.onInverseSurface,
                    width: 380,
                    child: Column(
                      children: [
                        Container(
                          color: Get.theme.colorScheme.primaryContainer,
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Center(
                            child: LPHTabElement(
                              tabs: SpaceSidebarTabType.values.map((e) => e.name.tr).toList(),
                              onTabSwitch: (el) {
                                final type = SpaceSidebarTabType.values.firstWhereOrNull((t) => t.name.tr == el);
                                if (type == null) {
                                  return;
                                }
                                SpaceController.sidebarTabType.value = type.index;
                              },
                              selected: SpaceController.sidebarTabType,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Watch((context) => _sidebarTabs[SpaceController.sidebarTabType.value]),
                        ),
                      ],
                    ),
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
