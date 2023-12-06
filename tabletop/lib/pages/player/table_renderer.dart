import 'package:flutter_animate/flutter_animate.dart';
import 'package:tabletop/layouts/templates/playable_canvas.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableRenderer extends StatefulWidget {

  final PlayableCanvas canvas;

  const TableRenderer({super.key, required this.canvas});

  @override
  State<TableRenderer> createState() => _TableRendererState();
}

class _TableRendererState extends State<TableRenderer> {

  final elementZoom = 0.5;

  final zoom = 2.0.obs;
  final position = const Offset(750, 400).obs;
  Offset? startPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        if(event.buttons == 4) {
          position.value += event.delta * (1/zoom.value);
        }
      },
      onPointerSignal: (event) {
        if(event is PointerScrollEvent) {
          zoom.value += event.scrollDelta.dy / 100 * 0.1 * -1;  
          if(zoom.value < 1) zoom.value = 1;
          if(zoom.value > 5) zoom.value = 5;
        }
      },
      child: Obx(() => Transform.scale(
        scale: zoom.value,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Get.theme.colorScheme.background,
              child: Stack(
                children: [
                  Stack(
                    children: List.generate(widget.canvas.layers.length, (index) {
                      final reverseIndex = widget.canvas.layers.length - index - 1;
                      final layer = widget.canvas.layers[reverseIndex];
                      return Obx(() => Stack(
                        children: List.generate(layer.elements.length, (index) {
                          final element = layer.elements.values.toList()[index];
                          final hovering = false.obs;
                      
                          return Obx(() {
                      
                            double adjustedLeft = (element.position.value.dx.toDouble() * elementZoom) + position.value.dx;
                            double adjustedTop = (element.position.value.dy.toDouble() * elementZoom) + position.value.dy;
                      
                            return Positioned(
                              left: adjustedLeft,
                              top: adjustedTop,
                              child: Transform.scale(
                                alignment: Alignment.topLeft,
                                scale: elementZoom,
                                child: MouseRegion(
                                  onEnter: (e) {
                                    hovering.value = true;
                                  },
                                  onExit: (e) {
                                    hovering.value = false;
                                  },
                                  child: GestureDetector(
                                    dragStartBehavior: DragStartBehavior.start,
                                    onTap: () {
                                      element.onGameClick(widget.canvas);
                                    },
                                    onPanUpdate: (details) {
                                      if(element.gameDragging()) {
                                        element.position.value = Offset(element.position.value.dx + (element.lockX ? 0 : details.delta.dx), element.position.value.dy + (element.lockY ? 0 :details.delta.dy));
                                      }
                                    },
                                    child: Animate(
                                      effects: [
                                        ScaleEffect(
                                          duration: 250.ms,
                                          curve: Curves.easeInOut,
                                          begin: const Offset(1.0,1.0),
                                          end: const Offset(1.4,1.4)
                                        )
                                      ],
                                      target: hovering.value ? 1.0 : 0,
                                      child: Obx(() {
                                          Widget child = element.build(context);
                                          for(var effect in element.effects) {
                                            child = effect.apply(element, child);
                                          }
                                          return element.buildParent(child);
                                        }
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ); 
                          });
                        }),
                      ));
                    }),
                  ),
                ],
              ),
            );
          }
        ),
      )),
    );
  }
}