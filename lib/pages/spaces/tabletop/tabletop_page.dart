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

  static Offset calculateMousePos(Offset local, double scale, Offset movement, TabletopController controller) {
    final angle = math.atan(local.dy / local.dx);
    final mouseAngle = angle - controller.canvasRotation.value;

    // Find position in circle
    final radius = local.distance;
    final x = radius * math.cos(mouseAngle);
    final y = radius * math.sin(mouseAngle);
    return Offset(x, y) / scale - movement;
  }
}

class _TabletopViewState extends State<TabletopView> with SingleTickerProviderStateMixin {
  var mousePos = const Offset(0, 0);
  var individualScale = 1.0;
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
              mousePos = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
              if (tableController.hoveringObjects.isEmpty) {
                individualScale = 1;
              }
              tableController.mousePos = mousePos;
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

                Get.dialog(ObjectCreateMenu(location: TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController)));
                //final obj = tableController.newObject(TableObjectType.square, "", calculateMousePos(event.localPosition, scale, offset), Size(100, 100), "");
                //obj.sendAdd();
              } else if (event.buttons == 1) {
                moved = false;
              }
            },
            onPointerMove: (event) {
              if (event.buttons == 4) {
                final old = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                final newPos = TabletopView.calculateMousePos(event.localPosition + event.delta, tableController.canvasZoom, tableController.canvasOffset, tableController);
                tableController.canvasOffset += newPos - old;
              } else if (event.buttons == 1) {
                if (tableController.hoveringObjects.isNotEmpty) {
                  moved = true;
                  tableController.heldObject ??= tableController.hoveringObjects.first;
                  final old = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                  final newPos = TabletopView.calculateMousePos(event.localPosition + event.delta, tableController.canvasZoom, tableController.canvasOffset, tableController);
                  tableController.heldObject!.location += newPos - old;
                  tableController.dropMode = false;
                }
              }
              mousePos = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
              tableController.mousePos = mousePos;
            },
            onPointerUp: (event) {
              individualScale = 1;
              if (tableController.hoveringObjects.isNotEmpty && !moved && event.buttons == 0) {
                tableController.hoveringObjects.first.runAction(tableController);
              }
              if (tableController.heldObject != null && tableController.dropMode) {
                sendLog("object dropped");
                tableController.dropMode = false;

                //tableController.heldObject!.sendAdd();
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

                if (tableController.canvasZoom + scrollDelta < 0.1) {
                  return;
                }
                if (tableController.canvasZoom + scrollDelta > 5) return;

                final zoomFactor = (tableController.canvasZoom + scrollDelta) / tableController.canvasZoom;
                final focalPoint = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
                final newFocalPoint = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom + scrollDelta, tableController.canvasOffset, tableController);

                tableController.canvasOffset -= focalPoint - newFocalPoint;
                tableController.canvasZoom *= zoomFactor;
                mousePos = TabletopView.calculateMousePos(event.localPosition, tableController.canvasZoom, tableController.canvasOffset, tableController);
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
                          individualScale: individualScale,
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
                      final focalPoint = TabletopView.calculateMousePos(center, tableController.canvasZoom, tableController.canvasOffset, tableController);
                      tableController.canvasRotation.value = value;
                      final newFocalPoint = TabletopView.calculateMousePos(center, tableController.canvasZoom, tableController.canvasOffset, tableController);

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
