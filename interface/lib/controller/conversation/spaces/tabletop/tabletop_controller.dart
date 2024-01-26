import 'dart:async';

import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_square.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopController extends GetxController {
  final loading = false.obs;
  final enabled = false.obs;

  List<TableObject> hoveringObjects = [];
  TableObject? heldObject;
  final objects = <String, TableObject>{}.obs;

  /// The rate at which the table is updated (to the server)
  static const tickRate = 20;
  Timer? _ticker;

  /// Join the tabletop session
  void connect() {
    if (enabled.value || loading.value) {
      return;
    }
    loading.value = true;

    spaceConnector.sendAction(
      Message("table_join", <String, dynamic>{}),
      handler: (event) {
        sendLog("hello world");
        loading.value = false;

        if (!event.data["success"]) {
          showErrorPopup("error", "server.error");
          return;
        }
        sendLog("success");
        enabled.value = true;

        _ticker = Timer.periodic(const Duration(milliseconds: 1000 ~/ tickRate), (timer) {
          _handleTableTick();
        });
      },
    );
  }

  /// Called every tick
  void _handleTableTick() {
    // Send the location of the held object
    if (heldObject != null) {
      spaceConnector.sendAction(Message("tobj_move", <String, dynamic>{
        "id": heldObject!.id,
        "x": heldObject!.location.dx,
        "y": heldObject!.location.dy,
      }));
    }
  }

  /// Leave the tabletop session
  void disconnect({bool leave = true}) {
    objects.clear();
    _ticker?.cancel();
    if (leave) {
      loading.value = true;
      spaceConnector.sendAction(
        Message("table_leave", <String, dynamic>{}),
        handler: (event) {
          loading.value = false;

          if (!event.data["success"]) {
            showErrorPopup("error", "server.error");
            return;
          }
          enabled.value = false;
        },
      );
    } else {
      enabled.value = false;
    }
  }

  /// Create a new object
  TableObject newObject(TableObjectType type, String id, Offset location, Size size, String data) {
    TableObject object;
    switch (type) {
      case TableObjectType.square:
        object = SquareObject(id, location, size, type);
        break;
    }
    object.importData(data);
    return object;
  }

  /// Add an object to the list
  void addObject(TableObject object) {
    if (object.id == "") {
      return;
    }
    objects[object.id] = object;
  }

  /// Remove an object from the list
  void removeObject({TableObject? object, String? id}) {
    objects.remove(id ?? object?.id);
  }

  /// Get the object at a location
  List<TableObject> raycast(Offset location) {
    final objects = <TableObject>[];
    for (var object in this.objects.values) {
      final rect = Rect.fromLTWH(object.location.dx, object.location.dy, object.size.width, object.size.height);
      if (rect.contains(location)) {
        objects.add(object);
      }
    }
    return objects;
  }
}

enum TableObjectType { square }

abstract class TableObject {
  TableObject(this.id, this.location, this.size, this.type);

  final String id;
  TableObjectType type;

  /// The size of the object
  Size size;

  /// The top left location of the object on the table
  DateTime? _lastMove;
  Offset? _lastLocation;
  Offset location;

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

  /// Required when getData is implemented
  void importData(String data) {}

  /// Implemented optionally when needed
  String getData() {
    return "";
  }

  /// Render with rotation and scale applied (used for movable objects)
  void render(Canvas canvas, Offset location, TabletopController controller) {}

  /// Called when the object is clicked
  void runAction(TabletopController controller) {}

  /// Called when the object is right clicked
  List<ContextMenuAction> getContextMenuAdditions() {
    return [];
  }

  /// Add a new object
  void sendAdd() {
    // Send to the server
    spaceConnector.sendAction(Message("tobj_create", <String, dynamic>{
      "x": location.dx,
      "y": location.dy,
      "type": type.index,
      "data": getData(),
    }));
  }

  /// Remove an object
  void sendRemove() {
    spaceConnector.sendAction(Message("tobj_delete", <String, dynamic>{
      "id": id,
    }));
  }
}

class ContextMenuAction {
  final IconData icon;
  final bool category;
  final String label;
  final Color? color;
  final Color? iconColor;
  final Function(TabletopController) onTap;

  const ContextMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.category = false,
    this.color,
    this.iconColor,
  });
}
