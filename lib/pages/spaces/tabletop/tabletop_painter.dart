import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      final location = controller.heldObject == object ? object.location : object.interpolatedLocation(now);
      if (!controller.hoveringObjects.contains(object)) {
        object.scale.setValue(1.0);
      }
      final scale = object.scale.value(now);
      canvas.save();
      canvas.scale(scale);
      canvas.translate(
        -(location.dx + object.size.width / 2) * ((scale - 1) / scale),
        -(location.dy + object.size.height / 2) * ((scale - 1) / scale),
      );
      object.render(canvas, location, controller);
      canvas.restore();
    }

    // Render held object in drop mode
    if (controller.dropMode && controller.heldObject != null) {
      final obj = controller.heldObject!;
      canvas.save();
      final scale = obj.scale.value(now);
      canvas.scale(scale);
      final x = mousePosition.dx - obj.size.width / 2;
      final y = mousePosition.dy - obj.size.height / 2;
      canvas.translate(
        -(x + obj.size.width / 2) * ((scale - 1) / scale),
        -(y + obj.size.height / 2) * ((scale - 1) / scale),
      );
      controller.heldObject?.render(
        canvas,
        Offset(
          x,
          y,
        ),
        controller,
      );
      canvas.restore();
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
    for (var object in controller.inventory) {
      if (object.downloaded) {
        final width = object.size.width / sizeReduction;
        final height = object.size.height / sizeReduction;
        final rect = Rect.fromLTWH(
          object.positionX.value(now),
          object.positionY.value(now),
          width,
          height,
        );

        // Tell the controller about the hover state
        final hovered = rect.contains(mousePositionUnmodified);
        if (hovered && !controller.hoveringObjects.contains(object)) {
          controller.hoveringObjects.add(object);
        } else if (!hovered && controller.hoveringObjects.contains(object)) {
          controller.hoveringObjects.remove(object);
        }
        object.scale.setValue(1.0);
        object.inventory = true;

        // Draw the card and update positions
        object.positionOverwrite = true;
        object.positionX.setValue(size.width / 2 + totalWidth / 2 - counterWidth);
        object.positionY.setValue(size.height - height / 2 - (hovered ? height / 2 * 1.2 : 0));
        final imageRect = Rect.fromLTWH(0, 0, object.imageSize!.width, object.imageSize!.height);
        final scale = object.scale.value(now);
        canvas.save();
        canvas.scale(scale);
        final x = object.positionX.value(now);
        final y = object.positionY.value(now);
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
}
