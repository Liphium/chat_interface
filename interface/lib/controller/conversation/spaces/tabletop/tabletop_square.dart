import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:flutter/material.dart';

class SquareObject extends TableObject {
  SquareObject(super.id, super.location, super.size, super.type);

  @override
  void render(Canvas canvas, Offset location) {
    canvas.drawRect(Rect.fromLTWH(location.dx, location.dy, size.width, size.height), Paint()..color = Colors.red);
  }
}
