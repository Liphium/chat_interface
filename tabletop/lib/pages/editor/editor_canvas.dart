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
  @override
  Widget build(BuildContext context) {
    return GetX<EditorController>(
      builder: (controller) {
        return GestureDetector(
          onTap: () => controller.currentElement.value = null,
          child: Container(
            color: Get.theme.colorScheme.primaryContainer,
            child: Stack(
              children: List.generate(controller.currentLayout.value.layers.length, (index) {
                final reverseIndex = controller.currentLayout.value.layers.length - index - 1;
                final layer = controller.currentLayout.value.layers[reverseIndex];
                return RepaintBoundary(
                  child: Stack(
                    children: List.generate(layer.elements.length, (index) {
                      final element = layer.elements.values.toList()[index];
                
                      return Obx(() {
                        return Positioned(
                          left: element.position.value.dx.toDouble(),
                          top: element.position.value.dy.toDouble(),
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
                        ); 
                      });
                    }),
                  ),
                );
              }),
            )
          ),
        );
      },
    );
  }
}