import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class TabletopView extends StatefulWidget {
  const TabletopView({super.key});

  @override
  State<TabletopView> createState() => _TabletopViewState();
}

class _TabletopViewState extends State<TabletopView> {
  final mousePos = const Offset(0, 0).obs;
  final offset = const Offset(0, 0).obs;
  final scale = 1.0.obs;
  final rotation = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerHover: (event) {
              mousePos.value = calculateMousePos(event.localPosition, scale.value) - offset.value;
            },
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                final scrollDelta = event.scrollDelta.dy / 500 * -1;
                if (scale.value + scrollDelta < 0.5) {
                  return;
                }
                if (scale.value + scrollDelta > 2) return;

                final zoomFactor = (scale.value + scrollDelta) / scale.value;
                final focalPoint = calculateMousePos(event.localPosition, scale.value) - offset.value;
                final newFocalPoint = calculateMousePos(event.localPosition, scale.value + scrollDelta) - offset.value;

                offset.value -= focalPoint - newFocalPoint;
                scale.value *= zoomFactor;
                mousePos.value = calculateMousePos(event.localPosition, scale.value) - offset.value;
              }
            },
            child: GestureDetector(
              onPanDown: (details) {},
              onPanUpdate: (details) {
                final old = calculateMousePos(details.localPosition, scale.value);
                final newPos = calculateMousePos(details.localPosition + details.delta, scale.value);
                offset.value += newPos - old;
              },
              onPanEnd: (details) {},
              child: SizedBox.expand(
                child: ClipRRect(
                  child: Obx(
                    () {
                      return CustomPaint(
                        painter: TabletopPainter(
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

  Offset calculateMousePos(Offset local, double scale) {
    final angle = math.atan(local.dy / local.dx);
    final mouseAngle = angle - rotation.value;
    sendLog("angle: ${angle * 180 / math.pi}");

    // Find position in circle
    final radius = local.distance;
    final x = radius * math.cos(mouseAngle);
    final y = radius * math.sin(mouseAngle);
    return Offset(x, y) / scale;
  }
}
