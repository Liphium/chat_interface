import 'dart:ui';

import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:get/get.dart';

void setupTabletopListeners() {
  final controller = Get.find<TabletopController>();

  spaceConnector.listen("table_obj", (event) {
    for (var obj in event.data["obj"]) {
      controller.addObject(controller.newObject(
        TableObjectType.values[obj["t"]],
        obj["id"],
        Offset((obj["x"] as num).toDouble(), (obj["y"] as num).toDouble()),
        Size((obj["w"] as num).toDouble(), (obj["h"] as num).toDouble()),
        obj["d"],
      ));
    }
  });

  // Listen for creations
  spaceConnector.listen("tobj_created", (event) {
    controller.addObject(controller.newObject(
      TableObjectType.values[event.data["type"]],
      event.data["id"],
      Offset((event.data["x"] as num).toDouble(), (event.data["y"] as num).toDouble()),
      Size((event.data["w"] as num).toDouble(), (event.data["h"] as num).toDouble()),
      event.data["data"],
    ));
  });

  // Listen for cursor movements
  spaceConnector.listen("tc_moved", (event) {
    controller.updateCursor(
      event.data["c"],
      Offset((event.data["x"] as num).toDouble(), (event.data["y"] as num).toDouble()),
    );
  });

  // Listen for deletions
  spaceConnector.listen("tobj_deleted", (event) {
    controller.removeObject(id: event.data["id"]);
  });

  // Listen for moves
  spaceConnector.listen("tobj_moved", (event) {
    final object = controller.objects[event.data["id"]];
    if (object == null || object == controller.heldObject) {
      return;
    }
    object.move(Offset((event.data["x"] as num).toDouble(), (event.data["y"] as num).toDouble()));
  });
}
