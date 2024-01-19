import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
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

class _TabletopViewState extends State<TabletopView> with SingleTickerProviderStateMixin {
  final mousePos = const Offset(0, 0).obs;
  final offset = const Offset(0, 0).obs;
  final scale = 1.0.obs;
  final rotation = 0.0.obs;

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
              mousePos.value = calculateMousePos(event.localPosition, scale.value, offset.value);
            },
            onPointerDown: (event) {
              if (event.buttons == 2) {
                final obj = tableController.newObject(TableObjectType.square, "", calculateMousePos(event.localPosition, scale.value, offset.value), Size(100, 100), "");
                obj.sendAdd();
                return;
              }
            },
            onPointerMove: (event) {
              sendLog(event.buttons);
              if (event.buttons == 4) {
                final old = calculateMousePos(event.localPosition, scale.value, offset.value);
                final newPos = calculateMousePos(event.localPosition + event.delta, scale.value, offset.value);
                offset.value += newPos - old;
              } else if (event.buttons == 1) {
                if (tableController.hoveringObject != null) {
                  tableController.heldObject = tableController.hoveringObject;
                  final old = calculateMousePos(event.localPosition, scale.value, offset.value);
                  final newPos = calculateMousePos(event.localPosition + event.delta, scale.value, offset.value);
                  tableController.hoveringObject!.location += newPos - old;
                }
              }
              mousePos.value = calculateMousePos(event.localPosition, scale.value, offset.value);
            },
            onPointerSignal: (event) {
              sendLog(event.runtimeType);
              if (event is PointerScrollEvent) {
                final scrollDelta = event.scrollDelta.dy / 500 * -1;
                if (scale.value + scrollDelta < 0.5) {
                  return;
                }
                if (scale.value + scrollDelta > 2) return;

                final zoomFactor = (scale.value + scrollDelta) / scale.value;
                final focalPoint = calculateMousePos(event.localPosition, scale.value, offset.value);
                final newFocalPoint = calculateMousePos(event.localPosition, scale.value + scrollDelta, offset.value);

                offset.value -= focalPoint - newFocalPoint;
                scale.value *= zoomFactor;
                mousePos.value = calculateMousePos(event.localPosition, scale.value, offset.value);
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
                          mousePosition: mousePos.value,
                          offset: offset.value,
                          scale: scale.value,
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
                    onChanged: (value) => rotation.value = value,
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
