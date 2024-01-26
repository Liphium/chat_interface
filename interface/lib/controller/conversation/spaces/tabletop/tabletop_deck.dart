import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';

class DeckObject extends TableObject {
  DeckObject(super.id, super.location, super.size, super.type);

  @override
  void render(Canvas canvas, Offset location, TabletopController controller) {
    // Draw a stack
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(location.dx, location.dy, size.width, size.height), paint);
  }

  @override
  void importData(String data) {}

  @override
  void runAction(TabletopController controller) {
    sendLog("this is an action");
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.rotate_left,
        label: 'Get cards',
        onTap: (controller) {},
      ),
    ];
  }
}
