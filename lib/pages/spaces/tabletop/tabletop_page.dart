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
}

class _TabletopViewState extends State<TabletopView>
    with SingleTickerProviderStateMixin {
  var mousePos = const Offset(0, 0);
  var offset = const Offset(0, 0);
  var scale = 1.0;
  var individualScale = 1.0;
  final rotation = 0.0.obs;
  bool moved = false;

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
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerHover: (event) {
              tableController.heldObject = null;
              mousePos = calculateMousePos(event.localPosition, scale, offset);
              if (tableController.hoveringObjects.isEmpty) {
                individualScale = 1;
              }
            },
            onPointerDown: (event) {
              if (event.buttons == 2) {
                if (tableController.hoveringObjects.isNotEmpty) {
                  final screenWidth = Get.mediaQuery.size.width;
                  final screenHeight = Get.mediaQuery.size.height;

                  // Convert local to global position
                  final globalPos = Offset(
                    event.localPosition.dx +
                        (screenWidth - context.size!.width),
                    event.localPosition.dy +
                        (screenHeight - context.size!.height),
                  );

                  Get.dialog(ObjectContextMenu(
                    data: ContextMenuData.fromPosition(globalPos),
                    object: tableController.hoveringObjects.first,
                  ));
                  return;
                }

                Get.dialog(ObjectCreateMenu(
                    location:
                        calculateMousePos(event.localPosition, scale, offset)));
                //final obj = tableController.newObject(TableObjectType.square, "", calculateMousePos(event.localPosition, scale, offset), Size(100, 100), "");
                //obj.sendAdd();
              } else if (event.buttons == 1) {
                moved = false;
              }
            },
            onPointerMove: (event) {
              if (event.buttons == 4) {
                final old =
                    calculateMousePos(event.localPosition, scale, offset);
                final newPos = calculateMousePos(
                    event.localPosition + event.delta, scale, offset);
                offset += newPos - old;
              } else if (event.buttons == 1) {
                if (tableController.hoveringObjects.isNotEmpty) {
                  moved = true;
                  tableController.heldObject ??=
                      tableController.hoveringObjects.first;
                  final old =
                      calculateMousePos(event.localPosition, scale, offset);
                  final newPos = calculateMousePos(
                      event.localPosition + event.delta, scale, offset);
                  tableController.heldObject!.location += newPos - old;
                }
              }
              mousePos = calculateMousePos(event.localPosition, scale, offset);
            },
            onPointerUp: (event) {
              individualScale = 1;
              if (tableController.hoveringObjects.isNotEmpty &&
                  !moved &&
                  event.buttons == 0) {
                tableController.hoveringObjects.first
                    .runAction(tableController);
              }
              tableController.heldObject = null;
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                final scrollDelta = event.scrollDelta.dy / 500 * -1;

                // Check if hover scale should be applied
                if (tableController.hoveringObjects.isNotEmpty) {
                  individualScale += scrollDelta * 2;
                  individualScale = individualScale.clamp(1, 5);
                  return;
                }

                if (scale + scrollDelta < 0.5) {
                  return;
                }
                if (scale + scrollDelta > 2) return;

                final zoomFactor = (scale + scrollDelta) / scale;
                final focalPoint =
                    calculateMousePos(event.localPosition, scale, offset);
                final newFocalPoint = calculateMousePos(
                    event.localPosition, scale + scrollDelta, offset);

                offset -= focalPoint - newFocalPoint;
                scale *= zoomFactor;
                mousePos =
                    calculateMousePos(event.localPosition, scale, offset);
              }
            },
            child: SizedBox.expand(
              child: ClipRRect(
                child: RepaintBoundary(
                  child: Obx(
                    () {
                      updater.value;
                      return CustomPaint(
                        willChange: true,
                        isComplex: true,
                        painter: TabletopPainter(
                          controller: tableController,
                          mousePosition: mousePos,
                          individualScale: individualScale,
                          offset: offset,
                          scale: scale,
                          rotation: rotation.value,
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
                    value: rotation.value,
                    onChanged: (value) {
                      final center = Offset(
                          context.size!.width / 2, context.size!.height / 2);
                      final focalPoint =
                          calculateMousePos(center, scale, offset);
                      rotation.value = value;
                      final newFocalPoint =
                          calculateMousePos(center, scale, offset);

                      offset -= focalPoint - newFocalPoint;
                    },
                    min: 0,
                    max: 2 * math.pi,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Offset calculateMousePos(Offset local, double scale, Offset movement) {
    final angle = math.atan(local.dy / local.dx);
    final mouseAngle = angle - rotation.value;

    // Find position in circle
    final radius = local.distance;
    final x = radius * math.cos(mouseAngle);
    final y = radius * math.sin(mouseAngle);
    return Offset(x, y) / scale - movement;
  }
}
