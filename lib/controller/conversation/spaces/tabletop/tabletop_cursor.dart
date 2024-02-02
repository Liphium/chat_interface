import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:flutter/material.dart';

class TabletopCursor {
  String clientId;

  DateTime? _lastMove;
  Offset? _lastLocation;
  Offset location;

  TabletopCursor(this.clientId, this.location);

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
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(interpolatedLocation(DateTime.now()), 10, paint);
  }
}
