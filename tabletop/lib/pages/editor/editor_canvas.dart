import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorCanvas extends StatefulWidget {

  const EditorCanvas({super.key});

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {

  final elementZoom = 0.5;

  final zoom = 2.0.obs;
  final position = const Offset(750, 400).obs;
  Offset? startPosition;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();
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
      child: GestureDetector(
        onTap: () => controller.currentElement.value = null,
        child: RepaintBoundary(
          child: Obx(() => Transform.scale(
            scale: zoom.value,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  color: Get.theme.colorScheme.background,
                  child: Stack(
                    children: [
                      Stack(
                        children: List.generate(controller.currentCanvas.value.layers.length, (index) {
                          final reverseIndex = controller.currentCanvas.value.layers.length - index - 1;
                          final layer = controller.currentCanvas.value.layers[reverseIndex];
                          return Stack(
                            children: List.generate(layer.elements.length, (index) {
                              final element = layer.elements.values.toList()[index];
                          
                              return Obx(() {
                          
                                double adjustedLeft = (element.position.value.dx.toDouble() * elementZoom) + position.value.dx;
                                double adjustedTop = (element.position.value.dy.toDouble() * elementZoom) + position.value.dy;
                          
                                return Positioned(
                                  left: adjustedLeft,
                                  top: adjustedTop,
                                  child: Transform.scale(
                                    alignment: Alignment.topLeft,
                                    scale: elementZoom,
                                    child: GestureDetector(
                                      dragStartBehavior: DragStartBehavior.start,
                                      onTap: () => controller.currentElement.value = element,
                                      onPanUpdate: (details) {
                                        if(controller.currentElement.value == element && !controller.renderMode.value) {
                                          element.position.value = Offset(element.position.value.dx + (element.lockX ? 0 : details.delta.dx), element.position.value.dy + (element.lockY ? 0 :details.delta.dy));
                                        }
                                      },
                                      onPanEnd: (details) => controller.save(),
                                      child: Stack(
                                        children: [
                                          RepaintBoundary(
                                            child: Container(
                                              decoration: controller.currentElement.value == element ? BoxDecoration(
                                                border: Border.all(
                                                  color: Get.theme.colorScheme.onPrimary,
                                                  width: 1,
                                                ),
                                              ) : null,
                                              padding: controller.currentElement.value == element ? null : const EdgeInsets.all(1),
                                              child: Obx(() {
                                                  Widget child = element.build(context);
                                                  for(var effect in element.effects) {
                                                    child = effect.apply(element, child);
                                                  }
                                                  return element.buildParent(child);
                                                }
                                              )
                                            ),
                                          ),
                                          Visibility(
                                            visible: element.scalable && controller.currentElement.value == element && !controller.renderMode.value,
                                            child: Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onPanUpdate: (details) {
                                                  element.size.value = Size(element.size.value.width + (element.scalableWidth ? details.delta.dx : 0), element.size.value.height + (element.scalableHeight ? details.delta.dy : 0));
                                                },
                                                onPanEnd: (details) => controller.save(),
                                                child: Container(
                                                  width: 10,
                                                  height: 10,
                                                  color: Get.theme.colorScheme.onPrimary,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ); 
                              });
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }
            ),
          )),
        ),
      ),
    );
  }
}