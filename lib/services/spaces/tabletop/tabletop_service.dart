import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_card.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_deck.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_inventory.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_text.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';

class TabletopService {
  static void setupTabletopListeners(Connector connector) {
    connector.listen("table_obj", (event) {
      for (var obj in event.data["obj"]) {
        TabletopController.addObject(
          newObject(
            TableObjectType.values[obj["t"]],
            obj["id"] as String,
            obj["o"] as int,
            Offset((obj["x"] as num).toDouble(), (obj["y"] as num).toDouble()),
            Size((obj["w"] as num).toDouble(), (obj["h"] as num).toDouble()),
            (obj["r"] as num).toDouble(),
            obj["d"],
          ),
        );
      }
    });

    // Listen for creations
    connector.listen("tobj_created", (event) {
      if (event.data["c"] == SpaceMemberController.getOwnId()) {
        return;
      }

      TabletopController.addObject(
        newObject(
          TableObjectType.values[event.data["type"]],
          event.data["id"],
          event.data["o"],
          Offset((event.data["x"] as num).toDouble(), (event.data["y"] as num).toDouble()),
          Size((event.data["w"] as num).toDouble(), (event.data["h"] as num).toDouble()),
          (event.data["r"] as num).toDouble(),
          event.data["data"],
        ),
      );
    });

    // Listen for a new order of an object
    connector.listen("tobj_order", (event) {
      var objectId = event.data["o"];
      var newOrder = (event.data["or"] as num).toInt();
      TabletopController.setOrder(objectId, newOrder);
    });

    // Listen for cursor movements
    connector.listen("tc_moved", (event) {
      TabletopController.updateCursor(
        event.data["c"],
        Offset((event.data["x"] as num).toDouble(), (event.data["y"] as num).toDouble()),
        (event.data["col"] as num).toDouble(),
      );
    });

    // Listen for deletions
    connector.listen("tobj_deleted", (event) {
      TabletopController.removeObject(id: event.data["id"]);
    });

    // Listen for moves
    connector.listen("tobj_moved", (event) {
      final object = TabletopController.objects[event.data["id"]];
      if (object == null || object == TabletopController.heldObject) {
        return;
      }
      object.move(Offset((event.data["x"] as num).toDouble(), (event.data["y"] as num).toDouble()));
    });

    // Listen for rotations
    connector.listen("tobj_rotated", (event) {
      final object = TabletopController.objects[event.data["id"]];
      if (object == null) {
        return;
      }
      object.rotate((event.data["r"] as num).toDouble());
    });

    // Listen for modifications
    connector.listen("tobj_modified", (event) {
      final object = TabletopController.objects[event.data["id"]];
      if (object == null) {
        return;
      }
      object.decryptData(event.data["data"]);
      sendLog(event.data["w"]);
      object.size = Size((event.data["w"] as num).toDouble(), (event.data["h"] as num).toDouble());
    });

    // Listen for when edits are allowed
    connector.listen("tobj_mqueue_allowed", (event) {
      final object = TabletopController.objects[event.data["id"]];
      if (object == null) {
        sendLog("object not found, modification can't be done");
        return;
      }
      object.dataCallback?.call();
    });
  }

  /// Create a new object
  static TableObject newObject(TableObjectType type, String id, int order, Offset location, Size size, double rotation, String data) {
    TableObject object;
    switch (type) {
      case TableObjectType.text:
        object = TextObject(id, order, location, size);
      case TableObjectType.deck:
        object = DeckObject(id, order, location, size);
      case TableObjectType.card:
        object = CardObject(id, order, location, size);
      case TableObjectType.inventory:
        object = InventoryObject(id, order, location, size);
    }
    object.rotate(rotation);
    object.decryptData(data);
    return object;
  }
}
