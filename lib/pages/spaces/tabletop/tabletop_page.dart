import 'dart:ui';

import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/object_context_menu.dart';
import 'package:chat_interface/pages/spaces/tabletop/object_create_menu.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class TabletopView extends StatefulWidget {
  const TabletopView({super.key});

  @override
  State<TabletopView> createState() => _TabletopViewState();

  static Offset localToWorldPos(Offset local, double scale, Offset movement, TabletopController controller) {
    final angle = math.atan(local.dy / local.dx);
    final mouseAngle = angle - controller.canvasRotation.value;

    // Find position in circle
    final radius = local.distance;
    final x = radius * math.cos(mouseAngle);
    final y = radius * math.sin(mouseAngle);
    return Offset(x, y) / scale - movement;
  }

  static Offset worldToLocalPos(Offset world, double scale, Offset movement, TabletopController controller) {
    // Undo the movement
    Offset withoutMovement = world + movement;

    // Reverse the scaling
    Offset unscaled = withoutMovement * scale;

    // Adjust for canvas rotation
    final dx = unscaled.dx;
    final dy = unscaled.dy;
    final radius = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx) - controller.canvasRotation.value;

    // Convert back to local coordinates
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);

    return Offset(x, y);
  }
}

class _TabletopViewState extends State<TabletopView> with SingleTickerProviderStateMixin {
  bool moved = false;
  final GlobalKey key = GlobalKey();

  final updater = false.obs;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 50.ms);
    _controller.loop();

    // Update every frame
    _controller.addListener(() {
      updater.value = !updater.value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableController = Get.find<TabletopController>();

    // Add post frame callback to tell the controller the size of the painter
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderObj = key.currentContext!.findRenderObject() as RenderBox;
      final widgetPosition = renderObj.localToGlobal(Offset.zero);
      tableController.globalCanvasPosition = widgetPosition;
    });

    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerHover: (event) {
              if (!tableController.dropMode) {
                tableController.heldObject = null;
              }
              tableController.mousePosUnmodified = event.localPosition;
              tableController.mousePos = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
            },
            onPointerDown: (event) {
              if (event.buttons == 2) {
                if (tableController.hoveringObjects.isNotEmpty) {
                  final screenWidth = Get.mediaQuery.size.width;
                  final screenHeight = Get.mediaQuery.size.height;

                  // Convert local to global position
                  final globalPos = Offset(
                    event.localPosition.dx + (screenWidth - context.size!.width),
                    event.localPosition.dy + (screenHeight - context.size!.height),
                  );

                  Get.dialog(ObjectContextMenu(
                    data: ContextMenuData.fromPosition(globalPos),
                    object: tableController.hoveringObjects.first,
                  ));
                  moved = true;
                  return;
                }

                Get.dialog(ObjectCreateMenu(location: TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController)));
              } else if (event.buttons == 1) {
                moved = false;
              }
            },
            onPointerMove: (event) {
              if (event.buttons == 4) {
                final old = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                final newPos = TabletopView.localToWorldPos(event.localPosition + event.delta, tableController.canvasZoom, tableController.canvasOffset, tableController);
                tableController.canvasOffset += newPos - old;
              } else if (event.buttons == 1) {
                if (tableController.hoveringObjects.isNotEmpty) {
                  if (tableController.heldObject != null) {
                    final old = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                    final newPos = TabletopView.localToWorldPos(event.localPosition + event.delta, tableController.canvasZoom, tableController.canvasOffset, tableController);
                    tableController.heldObject!.location += newPos - old;
                  } else {
                    moved = true;
                    tableController.heldObject ??= tableController.hoveringObjects.last;
                    final obj = tableController.heldObject!;
                    if (obj is CardObject && obj.inventory) {
                      tableController.inventory.remove(obj);
                      tableController.dropMode = true;
                      obj.inventory = false;
                    } else {
                      tableController.dropMode = false;
                    }
                  }
                }
              }
              tableController.mousePosUnmodified = event.localPosition;
              tableController.mousePos = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
            },
            onPointerUp: (event) {
              if (tableController.hoveringObjects.isNotEmpty && !moved && event.buttons == 0) {
                tableController.hoveringObjects.first.runAction(tableController);
              }
              sendLog(tableController.inventoryHoverIndex);

              final obj = tableController.heldObject;
              if (obj != null && tableController.dropMode) {
                tableController.dropMode = false;
                final x = tableController.mousePos.dx - obj.size.width / 2;
                final y = tableController.mousePos.dy - obj.size.height / 2;
                obj.location = Offset(x, y);
                bool add = true;
                if (obj is CardObject) {
                  if (tableController.inventoryHoverIndex != -1) {
                    obj.intoInventory(tableController, index: tableController.inventoryHoverIndex);
                    add = false;
                  } else {
                    obj.inventory = false;
                    obj.positionOverwrite = false;
                  }
                }
                if (add) {
                  obj.sendAdd();
                }
              } else if (!tableController.dropMode && obj != null && obj is CardObject) {
                if (tableController.inventoryHoverIndex != -1) {
                  obj.intoInventory(tableController, index: tableController.inventoryHoverIndex);
                }
              }
              tableController.heldObject = null;
              tableController.dropMode = false;
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                final scrollDelta = event.scrollDelta.dy / 500 * -1;

                // Check if hover scale should be applied
                if (tableController.hoveringObjects.isNotEmpty) {
                  for (var object in tableController.hoveringObjects) {
                    var current = object.scale.realValue;
                    current += scrollDelta * 2;
                    current = clampDouble(current, 1, 5);
                    object.scale.setValue(current);
                    object.scale.lastValue = object.scale.value(DateTime.now());
                  }
                  return;
                }

                if (tableController.canvasZoom + scrollDelta < 0.1) {
                  return;
                }
                if (tableController.canvasZoom + scrollDelta > 5) return;

                final zoomFactor = (tableController.canvasZoom + scrollDelta) / tableController.canvasZoom;
                final focalPoint = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                final newFocalPoint = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom + scrollDelta, tableController.canvasOffset, tableController);

                tableController.canvasOffset -= focalPoint - newFocalPoint;
                tableController.canvasZoom *= zoomFactor;
                tableController.mousePosUnmodified = event.localPosition;
              }
            },
            child: SizedBox.expand(
              child: ClipRRect(
                child: RepaintBoundary(
                  child: Obx(
                    () {
                      updater.value;
                      return CustomPaint(
                        key: key,
                        willChange: true,
                        isComplex: true,
                        painter: TabletopPainter(
                          controller: tableController,
                          mousePosition: tableController.mousePos,
                          mousePositionUnmodified: tableController.mousePosUnmodified,
                          offset: tableController.canvasOffset,
                          scale: tableController.canvasZoom,
                          rotation: tableController.canvasRotation.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              color: Colors.white,
              width: 200,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Slider(
                    value: tableController.canvasRotation.value,
                    onChanged: (value) {
                      final center = Offset(context.size!.width / 2, context.size!.height / 2);
                      final focalPoint = TabletopView.localToWorldPos(center, tableController.canvasZoom, tableController.canvasOffset, tableController);
                      tableController.canvasRotation.value = value;
                      final newFocalPoint = TabletopView.localToWorldPos(center, tableController.canvasZoom, tableController.canvasOffset, tableController);

                      tableController.canvasOffset -= focalPoint - newFocalPoint;
                    },
                    min: 0,
                    max: 2 * math.pi,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
