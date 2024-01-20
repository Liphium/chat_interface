import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopPainter extends CustomPainter {
  final TabletopController controller;
  final Offset offset;
  final Offset mousePosition;
  final double scale;
  final double individualScale;
  final double rotation;

  TabletopPainter({
    required this.controller,
    required this.offset,
    required this.mousePosition,
    required this.individualScale,
    this.scale = 1.0,
    this.rotation = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    //define canvas background color
    Paint background = Paint()..color = Get.theme.colorScheme.background;

    //define canvas size
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    // Rotate and stuff
    canvas.rotate(rotation);
    canvas.scale(scale);
    canvas.translate(offset.dx, offset.dy);

    final now = DateTime.now();
    controller.hoveringObjects = controller.raycast(mousePosition);

    for (var object in controller.objects.values) {
      final location = controller.heldObject == object ? object.location : object.interpolatedLocation(now);
      if (controller.hoveringObjects.contains(object)) {
        canvas.save();
        canvas.scale(individualScale);
        canvas.translate(
          -(location.dx + object.size.width / 2) * ((individualScale - 1) / individualScale),
          -(location.dy + object.size.height / 2) * ((individualScale - 1) / individualScale),
        );
      }
      object.render(canvas, location, controller);
      if (controller.hoveringObjects.contains(object)) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(TabletopPainter oldDelegate) {
    return true;
  }
}
