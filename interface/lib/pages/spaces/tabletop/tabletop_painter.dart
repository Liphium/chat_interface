import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopPainter extends CustomPainter {
  List<Rect> rects = [
    const Rect.fromLTWH(0, 0, 100, 100),
    const Rect.fromLTWH(100, 100, 100, 100),
    const Rect.fromLTWH(200, 200, 100, 100),
  ];

  final Offset offset;
  final Offset mousePosition;
  final double scale;
  final double rotation;

  TabletopPainter({required this.offset, required this.mousePosition, this.scale = 1.0, this.rotation = 0});

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
    for (var rect in rects) {
      final newRect = Rect.fromLTWH((rect.left + offset.dx), (rect.top + offset.dy), rect.width, rect.height);
      canvas.drawRect(newRect, Paint()..color = Colors.red);
    }

    canvas.drawCircle((mousePosition + offset), 5, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(TabletopPainter oldDelegate) {
    return true;
  }
}
