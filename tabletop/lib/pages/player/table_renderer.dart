import 'package:tabletop/layouts/templates/playable_canvas.dart';
import 'package:tabletop/layouts/canvas_manager.dart' as cv;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableRenderer extends StatefulWidget {

  final double zoom;
  final Offset position;
  final PlayableCanvas canvas;

  const TableRenderer({super.key, required this.position, required this.zoom, required this.canvas});

  @override
  State<TableRenderer> createState() => _TableRendererState();
}

class _TableRendererState extends State<TableRenderer> {

  final currentElement = Rx<cv.Element?>(null);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => {},
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Get.theme.colorScheme.background,
              child: Stack(
                children: List.generate(widget.canvas.layers.length, (index) {
                  final reverseIndex = widget.canvas.layers.length - index - 1;
                  final layer = widget.canvas.layers[reverseIndex];
                  return Stack(
                    children: List.generate(layer.elements.length, (index) {
                      final element = layer.elements.values.toList()[index];
                  
                      return Obx(() {
                  
                        double adjustedLeft = (element.position.value.dx.toDouble() * widget.zoom) + widget.position.dx;
                        double adjustedTop = (element.position.value.dy.toDouble() * widget.zoom) + widget.position.dy;
                  
                        return Positioned(
                          left: adjustedLeft,
                          top: adjustedTop,
                          child: Transform.scale(
                            alignment: Alignment.topLeft,
                            scale: widget.zoom,
                            child: GestureDetector(
                              dragStartBehavior: DragStartBehavior.start,
                              onTap: () {
                                if(element is DeckImageElement) {
                                  currentElement.value = element;
                                } else {
                                  element.onGameClick(widget.canvas);
                                  currentElement.value = null;
                                }
                              },
                              onPanUpdate: (details) {
                                if(currentElement.value == element && element is DeckImageElement) {
                                  element.position.value = Offset(element.position.value.dx + (element.lockX ? 0 : details.delta.dx), element.position.value.dy + (element.lockY ? 0 :details.delta.dy));
                                }
                              },
                              child: Stack(
                                children: [
                                  Obx(() {
                                      Widget child = element.build(context);
                                      for(var effect in element.effects) {
                                        child = effect.apply(element, child);
                                      }
                                      return element.buildParent(child);
                                    }
                                  ),
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