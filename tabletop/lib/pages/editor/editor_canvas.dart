import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorCanvas extends StatelessWidget {

  final double zoom;
  final Offset position;

  const EditorCanvas({super.key, required this.position, required this.zoom});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();
    return GestureDetector(
      onTap: () => controller.currentElement.value = null,
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Get.theme.colorScheme.background,
              child: Stack(
                children: List.generate(controller.currentCanvas.value.layers.length, (index) {
                  final reverseIndex = controller.currentCanvas.value.layers.length - index - 1;
                  final layer = controller.currentCanvas.value.layers[reverseIndex];
                  return Stack(
                    children: List.generate(layer.elements.length, (index) {
                      final element = layer.elements.values.toList()[index];
                  
                      return Obx(() {
                  
                        double adjustedLeft = (element.position.value.dx.toDouble() * zoom) + position.dx;
                        double adjustedTop = (element.position.value.dy.toDouble() * zoom) + position.dy;
                  
                        return Positioned(
                          left: adjustedLeft,
                          top: adjustedTop,
                          child: Transform.scale(
                            alignment: Alignment.topLeft,
                            scale: zoom,
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
                                  Container(
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
            );
          }
        ),
      ),
    );
  }
}