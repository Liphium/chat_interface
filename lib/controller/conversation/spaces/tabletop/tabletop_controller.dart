import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_cursor.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_deck.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopController extends GetxController {
  final loading = false.obs;
  final enabled = false.obs;

  /// If true, the next click will drop the held object and add it to the table
  bool dropMode = false;

  TableObject? heldObject;
  List<TableObject> hoveringObjects = [];
  final objects = <String, TableObject>{}.obs;
  final cursors = <String, TabletopCursor>{}.obs; // Other users cursors

  /// The rate at which the table is updated (to the server)
  static const tickRate = 20;
  Timer? _ticker;
  Offset? _lastMousePos;
  Offset? mousePos;

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

    // Send mouse position if available
    if (mousePos != null && _lastMousePos != mousePos) {
      spaceConnector.sendAction(Message("tc_move", <String, dynamic>{
        "x": mousePos!.dx,
        "y": mousePos!.dy,
      }));
    }

    _lastMousePos = mousePos;
  }

  /// Leave the tabletop session
  void disconnect({bool leave = true}) {
    objects.clear();
    _ticker?.cancel();
    cursors.clear();
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

  /// Update the cursor position of other people
  void updateCursor(String id, Offset position) {
    if (id == SpaceMemberController.ownId) {
      return;
    }

    if (cursors[id] == null) {
      cursors[id] = TabletopCursor(id, position);
    } else {
      cursors[id]!.move(position);
    }
  }

  /// Create a new object
  TableObject newObject(TableObjectType type, String id, Offset location, Size size, String data) {
    TableObject object;
    switch (type) {
      case TableObjectType.deck:
        object = DeckObject(id, location, size);
        break;
      case TableObjectType.card:
        object = DeckObject(id, location, size);
        break;
    }
    object.decryptData(data);
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

enum TableObjectType {
  deck(Icons.filter_none, "Deck"),
  card(Icons.image, "Card", creatable: false);

  final IconData icon;
  final String label;
  final bool creatable;

  const TableObjectType(this.icon, this.label, {this.creatable = true});
}

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

  /// DONT OVERWRITE THIS METHOD
  void decryptData(String data) {
    handleData(decryptSymmetric(data, SpacesController.key!));
  }

  /// NEVER CALL THIS METHOD WITH ENCRYPTED DATA
  void handleData(String data) {}

  /// Implemented optionally when needed
  String getData() {
    return "";
  }

  String encryptedData() {
    return encryptSymmetric(getData(), SpacesController.key!);
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
      "w": size.width,
      "h": size.height,
      "type": type.index,
      "data": encryptedData(),
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
