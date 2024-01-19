import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopPainter extends CustomPainter {
  final TabletopController controller;
  final Offset offset;
  final Offset mousePosition;
  final double scale;
  final double rotation;

  TabletopPainter({
    required this.controller,
    required this.offset,
    required this.mousePosition,
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
    final primary = Get.theme.colorScheme.onPrimary;
    controller.hoveringObject = controller.raycast(mousePosition);

    if (controller.hoveringObject != null) {
      final object = controller.hoveringObject!;
      final location = controller.heldObject == object ? object.location : object.interpolatedLocation(now);
      canvas.drawRect(Rect.fromLTWH(location.dx - 2, location.dy - 2, object.size.width + 4, object.size.height + 4), Paint()..color = primary);
    }

    for (var object in controller.objects.values) {
      final location = controller.heldObject == object ? object.location : object.interpolatedLocation(now);
      object.render(canvas, location);
    }
  }

  @override
  bool shouldRepaint(TabletopPainter oldDelegate) {
    return true;
  }
}
