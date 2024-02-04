import 'dart:async';
import 'dart:io';

import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class TabletopInventory extends StatefulWidget {
  final RxList<InventoryObject> inventory;

  const TabletopInventory({super.key, required this.inventory});

  @override
  State<TabletopInventory> createState() => _TabletopInventoryState();
}

class InventoryObject {
  final CardObject card;

  // For handling state
  final hovering = false.obs;
  final width = 0.0.obs;
  AnimationController? widthController;

  InventoryObject(this.card);
}

class _TabletopInventoryState extends State<TabletopInventory> {
  @override
  void initState() {
    super.initState();
    sendLog("COMPLETELY NEW");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.biggest.width;

        return Obx(
          () {
            // Pre-render pass
            double totalWidth = 0;
            for (var obj in widget.inventory) {
              totalWidth += obj.width.value / 2.5 + defaultSpacing;
            }
            double counterWidth = totalWidth;

            return Stack(
              children: widget.inventory.map((obj) {
                final width = obj.width.value / 2.5;
                final height = obj.card.size.height / 2.5;
                counterWidth -= width + defaultSpacing;

                return Positioned(
                  bottom: -height * 0.5,
                  left: screenWidth / 2 - totalWidth / 2 + counterWidth,
                  child: Obx(
                    () => Animate(
                      effects: [
                        MoveEffect(
                          duration: 250.ms,
                          curve: Curves.ease,
                          begin: const Offset(0, 0),
                          end: Offset(0, -height * 0.65),
                        ),
                      ],
                      target: obj.hovering.value ? 1 : 0,
                      child: Animate(
                        effects: [
                          ExpandEffect(
                            duration: 500.ms,
                            curve: scaleAnimationCurve,
                            axis: Axis.horizontal,
                            alignment: Alignment.center,
                          )
                        ],
                        autoPlay: false,
                        onInit: (controller) {
                          obj.widthController = controller;
                          controller.addListener(() {
                            obj.width.value = obj.card.size.width * scaleAnimationCurve.transform(controller.value);
                          });
                          if (obj.width.value == 0) {
                            controller.forward();
                          } else {
                            obj.width.value = obj.card.size.width;
                            controller.value = 1;
                          }
                        },
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (event) {
                              obj.hovering.value = true;
                            },
                            onExit: (event) {
                              obj.hovering.value = false;
                            },
                            child: Listener(
                              onPointerDown: (event) {},
                              onPointerMove: (event) {},
                              onPointerUp: (event) {
                                if (obj.widthController!.isAnimating) {
                                  return;
                                }
                                obj.widthController?.animateBack(0);
                                Timer(500.ms, () {
                                  Get.find<TabletopController>().inventory.remove(obj);
                                });
                                //Get.dialog(ImagePreviewWindow(file: File(obj.card.container.filePath)));
                              },
                              child: Image.file(File(obj.card.container.filePath)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
