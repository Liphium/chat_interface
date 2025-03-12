import 'dart:async';

import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_card.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_deck.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/object_context_menu.dart';
import 'package:chat_interface/pages/spaces/tabletop/object_create_menu.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import 'package:signals/signals_flutter.dart';

class TabletopView extends StatefulWidget {
  const TabletopView({super.key});

  @override
  State<TabletopView> createState() => _TabletopViewState();

  static Offset localToWorldPos(Offset local, double scale, Offset movement) {
    final angle = math.atan(local.dy / local.dx);
    final mouseAngle = angle - TabletopController.canvasRotation.value;

    // Find position in circle
    final radius = local.distance;
    final x = radius * math.cos(mouseAngle);
    final y = radius * math.sin(mouseAngle);
    return Offset(x, y) / scale - movement;
  }

  static Offset worldToLocalPos(Offset world, double scale, Offset movement) {
    // Undo the movement
    Offset withoutMovement = world + movement;

    // Reverse the scaling
    Offset unscaled = withoutMovement * scale;

    // Adjust for canvas rotation
    final dx = unscaled.dx;
    final dy = unscaled.dy;
    final radius = math.sqrt(dx * dx + dy * dy);
    final angle = math.atan2(dy, dx) + TabletopController.canvasRotation.value;

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
    final setting = SettingController.settings[TabletopSettings.framerate]! as Setting<double>;
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
    // Add post frame callback to tell the controller the size of the painter
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final renderObj = _key.currentContext!.findRenderObject() as RenderBox;
      final widgetPosition = renderObj.localToGlobal(Offset.zero);
      TabletopController.globalCanvasPosition = widgetPosition;
    });

    return Scaffold(
      body: RepaintBoundary(
        child: Watch(
          (context) {
            updater.value;
            return Listener(
              onPointerHover: (event) {
                TabletopController.mousePosUnmodified = event.localPosition;
                TabletopController.mousePos = TabletopView.localToWorldPos(
                  event.localPosition,
                  TabletopController.canvasZoom,
                  TabletopController.canvasOffset,
                );
              },
              onPointerDown: (event) {
                if (event.buttons == 2) {
                  if (TabletopController.hoveringObjects.isNotEmpty) {
                    Get.dialog(ObjectContextMenu(
                      data: ContextMenuData.fromPosition(Offset(event.position.dx, event.position.dy)),
                      object: TabletopController.hoveringObjects.first,
                    ));
                    moved = true;
                    return;
                  }

                  Get.dialog(ObjectCreateMenu(
                      location: TabletopView.localToWorldPos(
                    event.localPosition,
                    TabletopController.canvasZoom,
                    TabletopController.canvasOffset,
                  )));
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
                  final old = TabletopView.localToWorldPos(
                    event.localPosition,
                    TabletopController.canvasZoom,
                    TabletopController.canvasOffset,
                  );
                  final newPos = TabletopView.localToWorldPos(
                    event.localPosition + event.delta,
                    TabletopController.canvasZoom,
                    TabletopController.canvasOffset,
                  );
                  TabletopController.canvasOffset += newPos - old;
                }

                // Move the currently held object when the mouse is clicked
                if (event.buttons == 1) {
                  if (TabletopController.hoveringObjects.isNotEmpty && !TabletopController.cancelledHolding) {
                    // If there is a held object, move it, if not, add a new held object from the hovering objects list
                    if (TabletopController.heldObject != null) {
                      // Move the object
                      final old = TabletopView.localToWorldPos(
                        event.localPosition,
                        TabletopController.canvasZoom,
                        TabletopController.canvasOffset,
                      );
                      final newPos = TabletopView.localToWorldPos(
                        event.localPosition + event.delta,
                        TabletopController.canvasZoom,
                        TabletopController.canvasOffset,
                      );
                      TabletopController.heldObject!.location += newPos - old;
                    } else {
                      moved = true;

                      // Start holding the object
                      TabletopController.startHoldingObject(TabletopController.hoveringObjects.last);
                    }
                  }
                }

                // Update the mouse position in the controller
                TabletopController.mousePosUnmodified = event.localPosition;
                TabletopController.mousePos = TabletopView.localToWorldPos(
                  event.localPosition,
                  TabletopController.canvasZoom,
                  TabletopController.canvasOffset,
                );
              },

              //* Handle when a mouse button is no longer pressed
              onPointerUp: (event) {
                TabletopController.cancelledHolding = false;
                if (TabletopController.hoveringObjects.isNotEmpty && !moved && TabletopController.heldObject == null && event.buttons == 0) {
                  TabletopController.hoveringObjects.first.runAction();
                  return;
                }

                final obj = TabletopController.heldObject;
                if (obj != null && obj is CardObject) {
                  if (TabletopController.inventory != null && TabletopController.inventory?.inventoryHoverIndex != -1) {
                    obj.intoInventory(index: TabletopController.inventory?.inventoryHoverIndex);
                  } else if (TabletopController.hoveringObjects.any((element) => element is DeckObject)) {
                    final deck = TabletopController.hoveringObjects.firstWhere((element) => element is DeckObject) as DeckObject;
                    deck.addCard(obj);
                  }
                }

                // Stop the selection
                TabletopController.stopHoldingObject(error: TabletopController.cancelledHolding);
              },
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  final scrollDelta = event.scrollDelta.dy / 500 * -1;
                  if (TabletopController.canvasZoom + scrollDelta < 0.1) {
                    return;
                  }
                  if (TabletopController.canvasZoom + scrollDelta > 5) return;

                  final zoomFactor = (TabletopController.canvasZoom + scrollDelta) / TabletopController.canvasZoom;
                  final focalPoint =
                      TabletopView.localToWorldPos(event.localPosition, TabletopController.canvasZoom, TabletopController.canvasOffset);
                  final newFocalPoint =
                      TabletopView.localToWorldPos(event.localPosition, TabletopController.canvasZoom + scrollDelta, TabletopController.canvasOffset);

                  TabletopController.canvasOffset -= focalPoint - newFocalPoint;
                  TabletopController.canvasZoom *= zoomFactor;
                  TabletopController.mousePosUnmodified = event.localPosition;
                }
              },
              child: SizedBox.expand(
                child: ClipRRect(
                  child: CustomPaint(
                    key: _key,
                    willChange: true,
                    isComplex: true,
                    painter: TabletopPainter(
                      mousePosition: TabletopController.mousePos,
                      mousePositionUnmodified: TabletopController.mousePosUnmodified,
                      offset: TabletopController.canvasOffset,
                      scale: TabletopController.canvasZoom,
                      rotation: TabletopController.canvasRotation.value,
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
