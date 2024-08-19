import 'dart:async';
import 'dart:ui';

import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_deck.dart';
import 'package:chat_interface/pages/settings/app/tabletop_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
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
    final angle = math.atan2(dy, dx) + controller.canvasRotation.value;

    // Convert back to local coordinates
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);

    return Offset(x, y);
  }
}

class _TabletopViewState extends State<TabletopView> with SingleTickerProviderStateMixin {
  bool moved = false;
  final GlobalKey _key = GlobalKey();

  final updater = false.obs;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final setting = Get.find<SettingController>().settings[TabletopSettings.framerate]! as Setting<double>;
    setting.value.listenAndPump((value) => startFrameTimer(value!));
  }

  void startFrameTimer(double value) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic((1000 / value).ms, (timer) {
      updater.value = !updater.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tableController = Get.find<TabletopController>();

    // Add post frame callback to tell the controller the size of the painter
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderObj = _key.currentContext!.findRenderObject() as RenderBox;
      final widgetPosition = renderObj.localToGlobal(Offset.zero);
      tableController.globalCanvasPosition = widgetPosition;
    });

    return Scaffold(
      body: RepaintBoundary(
        child: Obx(
          () {
            updater.value;
            return Listener(
              onPointerHover: (event) {
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

              //* Handle the mouse movements
              onPointerMove: (event) {
                // Calculate the new position of the mouse
                final added = event.localPosition + event.delta;

                // Make sure the mouse isn't anywhere out of bounds
                if (added.dx <= 0 || added.dy <= 0 || event.localPosition.dx <= 0 || event.localPosition.dy <= 0) return;

                // Move the canvas when the mouse wheel is pressed
                if (event.buttons == 4) {
                  final old = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                  final newPos = TabletopView.localToWorldPos(event.localPosition + event.delta, tableController.canvasZoom, tableController.canvasOffset, tableController);
                  tableController.canvasOffset += newPos - old;
                }

                // Move the currently held object when the mouse is clicked
                if (event.buttons == 1) {
                  if (tableController.hoveringObjects.isNotEmpty && !tableController.cancelledHolding) {
                    // If there is a held object, move it, if not, add a new held object from the hovering objects list
                    if (tableController.heldObject != null) {
                      // Move the object
                      final old = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                      final newPos = TabletopView.localToWorldPos(event.localPosition + event.delta, tableController.canvasZoom, tableController.canvasOffset, tableController);
                      tableController.heldObject!.location += newPos - old;
                    } else {
                      moved = true;

                      sendLog("hiii");

                      // Start holding the object
                      tableController.startHoldingObject(tableController.hoveringObjects.last);
                    }
                  }
                }

                // Update the mouse position in the controller
                tableController.mousePosUnmodified = event.localPosition;
                tableController.mousePos = TabletopView.localToWorldPos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
              },

              //* Handle when a mouse button is no longer pressed
              onPointerUp: (event) {
                if (tableController.hoveringObjects.isNotEmpty && !moved && tableController.heldObject == null && event.buttons == 0) {
                  tableController.hoveringObjects.first.runAction(tableController);
                  return;
                }
                sendLog(tableController.inventoryHoverIndex);

                final obj = tableController.heldObject;
                if (obj != null && obj is CardObject) {
                  if (tableController.inventoryHoverIndex != -1) {
                    obj.intoInventory(tableController, index: tableController.inventoryHoverIndex);
                  } else if (tableController.hoveringObjects.any((element) => element is DeckObject)) {
                    final deck = tableController.hoveringObjects.firstWhere((element) => element is DeckObject) as DeckObject;
                    deck.addCard(obj);
                  }
                }

                // Stop the selection
                tableController.stopHoldingObject(error: tableController.cancelledHolding);
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
                  child: CustomPaint(
                    key: _key,
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
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
