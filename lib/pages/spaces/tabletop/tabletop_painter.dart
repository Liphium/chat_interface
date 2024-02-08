import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:math' as math;

class TabletopPainter extends CustomPainter {
  final TabletopController controller;
  final Offset offset;
  final Offset mousePosition;
  final Offset mousePositionUnmodified;
  final double scale;
  final double rotation;

  TabletopPainter({
    required this.controller,
    required this.offset,
    required this.mousePosition,
    required this.mousePositionUnmodified,
    this.scale = 1.0,
    this.rotation = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Get.theme.colorScheme.background;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    // Rotate and stuff
    canvas.save();
    canvas.rotate(rotation);
    canvas.scale(scale);
    canvas.translate(offset.dx, offset.dy);

    final now = DateTime.now();
    controller.hoveringObjects = controller.raycast(mousePosition);

    for (var object in controller.objects.values) {
      if (controller.hoveringObjects.contains(object) || controller.heldObject == object) {
        continue;
      }
      final location = controller.heldObject == object ? object.location : object.interpolatedLocation(now);
      object.scale.setValue(1.0);
      object.rotation.setValue(0);
      drawObject(canvas, location, object, now);
    }

    for (var object in controller.hoveringObjects) {
      final location = controller.heldObject == object ? object.location : object.interpolatedLocation(now);
      object.rotation.setValue(-rotation);
      drawObject(canvas, location, object, now);
    }

    // Render held object in drop mode
    if (controller.dropMode && controller.heldObject != null) {
      final obj = controller.heldObject!;
      final x = mousePosition.dx - obj.size.width / 2;
      final y = mousePosition.dy - obj.size.height / 2;
      drawObject(canvas, Offset(x, y), obj, now);
    } else if (!controller.dropMode && controller.heldObject != null) {
      final location = controller.heldObject!.location;
      drawObject(canvas, location, controller.heldObject!, now);
    }

    // Render cursors
    for (var cursor in controller.cursors.values) {
      cursor.render(canvas);
    }

    // UI goes after this
    canvas.restore();

    //* Draw inventory
    // Prerender pass
    const sizeReduction = 2.5;
    double totalWidth = 0;
    int index = 0;
    for (var object in controller.inventory) {
      totalWidth += object.size.width / sizeReduction + (index == 0 ? 0 : defaultSpacing);
      index++;
    }
    double counterWidth = totalWidth;

    // Render pass
    if (controller.heldObject != null) {
      controller.inventoryHoverIndex = -1;
    }
    bool found = false;
    for (var object in controller.inventory) {
      if (object.downloaded) {
        final width = object.size.width / sizeReduction;
        final height = object.size.height / sizeReduction;
        final x = object.positionX.value(now);
        final y = object.positionY.value(now);
        final rect = Rect.fromLTWH(
          x,
          y,
          width,
          height,
        );

        // Tell the controller about the hover state
        final hovered = rect.contains(mousePositionUnmodified) && controller.heldObject == null;
        if (hovered && !controller.hoveringObjects.contains(object)) {
          controller.hoveringObjects.insert(0, object);
        } else if (!hovered && controller.hoveringObjects.contains(object)) {
          controller.hoveringObjects.remove(object);
        }
        object.scale.setValue(1.0);
        object.inventory = true;

        // Dragging behavior
        var calcX = size.width / 2 + totalWidth / 2 - counterWidth;
        final calcY = size.height - height / 2 - (hovered ? height / 2 * 1.2 : 0);
        if (controller.heldObject != null && mousePositionUnmodified.dy > y) {
          if (controller.mousePosUnmodified.dx - width / 2 > x) {
            calcX -= 100;
          } else {
            calcX += 100;
            if (!found) {
              found = true;
              if (controller.inventoryHoverIndex == -1) {
                controller.inventoryHoverIndex = 0;
              }
            }
          }
          if (!found) {
            controller.inventoryHoverIndex = controller.inventoryHoverIndex < 0 ? 1 : controller.inventoryHoverIndex + 1;
          }
        }

        // Draw the card and update positions
        object.positionOverwrite = true;
        object.positionX.setValue(calcX);
        object.positionY.setValue(calcY);
        final imageRect = Rect.fromLTWH(0, 0, object.imageSize!.width, object.imageSize!.height);
        final scale = object.scale.value(now);
        canvas.save();
        canvas.scale(scale);
        canvas.translate(
          -(x + width / 2) * ((scale - 1) / scale),
          -(y + height / 2) * ((scale - 1) / scale),
        );
        canvas.drawImageRect(
          object.image!,
          imageRect,
          rect,
          Paint()..color = Colors.white,
        );

        canvas.restore();
        counterWidth -= width + defaultSpacing;
      }
    }
  }

  @override
  bool shouldRepaint(TabletopPainter oldDelegate) {
    return true;
  }

  void drawObject(Canvas canvas, Offset location, TableObject object, DateTime now) {
    final scale = object.scale.value(now);
    canvas.save();
    final focalX = location.dx + object.size.width / 2;
    final focalY = location.dy + object.size.height / 2;
    canvas.translate(focalX, focalY);
    canvas.rotate(object.rotation.value(now));
    canvas.scale(scale);
    canvas.translate(-focalX, -focalY);
    object.render(canvas, location, controller);
    canvas.restore();
  }
}
