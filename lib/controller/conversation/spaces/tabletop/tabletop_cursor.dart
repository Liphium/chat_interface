import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:flutter/material.dart';

class TabletopCursor {
  String clientId;

  DateTime? _lastMove;
  Offset? _lastLocation;
  Offset location;
  Color color;

  TabletopCursor(this.clientId, this.location, this.color);

  Offset interpolatedLocation(DateTime now) {
    if (_lastMove == null || _lastLocation == null) {
      return location;
    }
    final time = now.difference(_lastMove!).inMilliseconds;
    final delta = time / (1000 ~/ TabletopController.tickRate);
    return Offset.lerp(_lastLocation!, location, delta.clamp(0, 1))!;
  }

  void move(Offset location) {
    _lastMove = DateTime.now();
    _lastLocation = this.location;
    this.location = location;
  }

  void render(Canvas canvas) {
    final now = DateTime.now();
    if (_lastMove != null && now.difference(_lastMove!).inSeconds > 1) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(interpolatedLocation(DateTime.now()), 10, paint);
  }
}
