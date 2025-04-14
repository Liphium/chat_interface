import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopPainter extends CustomPainter {
  final Offset offset;
  final Offset mousePosition;
  final Offset mousePositionUnmodified;
  final double scale;
  final double rotation;

  TabletopPainter({
    required this.offset,
    required this.mousePosition,
    required this.mousePositionUnmodified,
    this.scale = 1.0,
    this.rotation = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Get.theme.colorScheme.inverseSurface;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    // Draw a grid
    /*
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    final paint = Paint()
      ..color = Get.theme.colorScheme.onSurface.withOpacity(0.1)
      ..strokeWidth = 1.0;

    final gridSize = 200.0 * scale;

    // Calculate the maximum distance needed to cover rotated corners
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    final extraSpace = (diagonal - math.min(size.width, size.height)) / 2;

    // Extend drawing area
    final startX = ((offset.dx * scale + extraSpace) % gridSize) - gridSize - extraSpace;
    final endX = size.width + extraSpace;
    final startY = ((offset.dy * scale + extraSpace) % gridSize) - gridSize - extraSpace;
    final endY = size.height + extraSpace;

    // Draw vertical lines
    for (double x = startX; x < endX; x += gridSize) {
      canvas.drawLine(
        Offset(x, -extraSpace),
        Offset(x, size.height + extraSpace),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = startY; y < endY; y += gridSize) {
      canvas.drawLine(
        Offset(-extraSpace, y),
        Offset(size.width + extraSpace, y),
        paint,
      );
    }

    canvas.restore();
    */

    // Rotate and stuff
    canvas.save();
    canvas.rotate(rotation);
    canvas.scale(scale);
    canvas.translate(offset.dx, offset.dy);

    /*
    // Draw grid in world mode
    final paint = Paint()
      ..color = Get.theme.colorScheme.onSurface.withOpacity(0.1)
      ..strokeWidth = 1.0;

    final gridSize = 200.0;

    // Calculate top-left world position
    final startX = -offset.dx + (offset.dx % gridSize) - gridSize;
    final startY = -offset.dy + (offset.dy % gridSize) - gridSize;
    final endX = -offset.dx + (size.width * scale) + (offset.dx % gridSize) + gridSize;
    final endY = -offset.dy + (size.height * scale) + (offset.dy % gridSize) + gridSize;

    canvas.drawCircle(-offset, 20, paint..color = Colors.blue);

    // Draw grid
    for (double x = startX; x < endX; x += gridSize) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }

    for (double y = startY; y < endY; y += gridSize) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint,
      );
    }
    */

    final now = DateTime.now();
    TabletopController.hoveringObjects = TabletopController.raycast(mousePosition);
    for (var i in TabletopController.orderSorted) {
      // Get the object at the current drawing layer
      final objectId = TabletopController.objectOrder[i];
      if (objectId == null) {
        continue;
      }

      // Render the object
      final object = TabletopController.objects[objectId]!;
      if (TabletopController.hoveringObjects.contains(object)) {
        object.hoverRotation(-rotation);
      } else {
        object.scale.setValue(1.0);
        object.unhoverRotation();
      }
      final location =
          TabletopController.heldObject == object
              ? object.location
              : object.interpolatedLocation(now);
      drawObject(canvas, location, object, now);
    }

    // Render cursors
    for (var cursor in TabletopController.cursors.value.values) {
      cursor.render(canvas);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(TabletopPainter oldDelegate) {
    return true;
  }

  /// Apply the nessecary scaling and rotation for object drawing (called before object rendering)
  static void preDraw(
    Canvas canvas,
    Offset location,
    TableObject object,
    DateTime now, {
    bool rotation = true,
  }) {
    final scale = object.scale.value(now);
    canvas.save();
    final focalX = location.dx + object.size.width / 2;
    final focalY = location.dy + object.size.height / 2;
    canvas.translate(focalX, focalY);
    if (rotation) {
      canvas.rotate(object.rotation.value(now));
    }
    canvas.scale(scale);
    canvas.translate(-focalX, -focalY);
  }

  /// Finish the drawing process of the object
  static void postDraw(Canvas canvas) {
    canvas.restore();
  }

  /// Draw an object to the table
  void drawObject(Canvas canvas, Offset location, TableObject object, DateTime now) {
    preDraw(canvas, location, object, now);
    object.render(canvas, location);
    postDraw(canvas);
  }
}
