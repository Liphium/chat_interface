import 'dart:async';

import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:flutter/material.dart';

abstract class TableObject {
  TableObject(this.id, this.order, this.location, this.size, this.type);

  Function()? dataCallback;
  String id;
  int order;
  TableObjectType type;

  /// The size of the object
  Size size;

  /// The top left location of the object on the table
  String? dataBeforeQueue;
  DateTime? _lastMove;
  Offset? _lastLocation;
  Offset location;
  bool deleted = false;
  bool added = false;

  // Modifiers
  bool positionOverwrite = false;
  final positionX = AnimatedDouble(0.0);
  final positionY = AnimatedDouble(0.0);
  final rotation = AnimatedDouble(0.0);
  final scale = AnimatedDouble(1.0, from: 0.0);

  Offset interpolatedLocation(DateTime now) {
    if (positionOverwrite) {
      return Offset(positionX.value(now), positionY.value(now));
    }
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

  double lastRotation = 0;
  void rotate(double rot) {
    sendLog(lastRotation);
    if (lastRotation == -1) {
      rotation.setValue(rot);
    } else {
      lastRotation = rot;
    }
  }

  void newRotation(double rot) {
    queue(() async {
      final event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("tobj_rotate", <String, dynamic>{
        "id": id,
        "r": rot,
      }));
      currentlyModifying = false;

      // Check if there was an error with the rotation
      if (event == null) {
        sendLog("error with object rotation: no response");
        return;
      }
      if (!event.data["success"]) {
        sendLog("error with object rotation: ${event.data["message"]}");
      }
    });
  }

  /// Called every frame when the object is hovered
  void hoverRotation(double rot) {
    if (lastRotation == -1) {
      lastRotation = rotation.realValue;
    }
    rotation.setValue(rot);
  }

  /// Called every frame when the object is no longer hovered
  void unhoverRotation() {
    if (lastRotation != -1) {
      rotation.setValue(lastRotation);
      lastRotation = -1;
    }
  }

  /// DONT OVERWRITE THIS METHOD
  void decryptData(String data) {
    handleData(decryptSymmetric(data, SpaceController.key!));
  }

  /// NEVER CALL THIS METHOD WITH ENCRYPTED DATA
  void handleData(String data) {}

  /// Implemented optionally when needed
  String getData() {
    return "";
  }

  String encryptedData() {
    return encryptSymmetric(getData(), SpaceController.key!);
  }

  /// Render with rotation and scale applied (used for movable objects)
  void render(Canvas canvas, Offset location) {}

  /// Called when the object is clicked
  void runAction() {}

  /// Called when the object is right clicked
  List<ContextMenuAction> getContextMenuAdditions() {
    return [];
  }

  /// Add a new object
  Future<bool> sendAdd() {
    deleted = false;
    if (added) {
      sendLog("WHAT DA HELL");
    }
    added = true;
    final completer = Completer<bool>();

    // Send to the server
    SpaceConnection.spaceConnector!.sendAction(
      ServerAction("tobj_create", <String, dynamic>{
        "x": location.dx,
        "y": location.dy,
        "w": size.width,
        "h": size.height,
        "r": lastRotation,
        "type": type.index,
        "data": encryptedData(),
      }),
      handler: (event) {
        if (!event.data["success"]) {
          sendLog("SOMETHING WENT WRONG");
          completer.complete(false);
          return;
        }
        id = event.data["id"];
        order = event.data["o"];
        sendLog("ADDING $id to table with order $order");
        TabletopController.addObject(this);
        completer.complete(true);
      },
    );

    return completer.future;
  }

  /// Remove an object
  void sendRemove() {
    deleted = true;
    added = false;
    SpaceConnection.spaceConnector!.sendAction(ServerAction("tobj_delete", id));
  }

  /// Start a modification process (data)
  Future<bool> select() {
    final completer = Completer<bool>();

    SpaceConnection.spaceConnector!.sendAction(
      ServerAction("tobj_select", id),
      handler: (event) {
        if (!event.data["success"]) {
          showErrorPopup("error", event.data["message"]);
          sendLog("can't select rn");
          completer.complete(false);
          return;
        }
        completer.complete(true);
      },
    );

    return completer.future;
  }

  /// Start a modification process (data)
  Future<bool> unselect() {
    final completer = Completer<bool>();
    if (deleted) {
      completer.complete(false);
    } else {
      SpaceConnection.spaceConnector!.sendAction(
        ServerAction("tobj_unselect", id),
        handler: (event) {
          if (!event.data["success"]) {
            sendLog("can't unselect rn");
            completer.complete(false);
            return;
          }
          completer.complete(true);
        },
      );
    }

    return completer.future;
  }

  // Boolean to make sure the object is not modified
  bool currentlyModifying = false;

  /// Wait until the data can be modified
  void queue(Function() callback) {
    if (currentlyModifying) {
      return;
    }
    currentlyModifying = true;
    dataBeforeQueue = getData();
    SpaceConnection.spaceConnector!.sendAction(
      ServerAction("tobj_mqueue", id),
      handler: (event) {
        if (!event.data["success"]) {
          showErrorPopup("error", event.data["message"]);
          return;
        }

        if (event.data["direct"]) {
          callback();
        } else {
          dataCallback = callback;
        }
      },
    );
  }

  /// Update the data of the object
  Future<bool> modifyData() {
    final completer = Completer<bool>();
    SpaceConnection.spaceConnector!.sendAction(
      ServerAction("tobj_modify", <String, dynamic>{
        "id": id,
        "data": encryptedData(),
        "width": size.width,
        "height": size.height,
      }),
      handler: (event) {
        currentlyModifying = false;
        // Reset data in case the modification wasn't successful
        if (!event.data["success"]) {
          if (dataBeforeQueue == null) {
            sendLog("NO ROLLBACK STATE FOR OBJECT");
            return;
          }

          sendLog("modification of $id wasn't possible: ${event.data["message"]}");
          handleData(dataBeforeQueue!);
          completer.complete(false);
        } else {
          completer.complete(true);
        }

        // Reset it
        dataBeforeQueue = null;
      },
    );
    return completer.future;
  }
}

enum TableObjectType {
  text(Icons.text_fields, "Text"),
  deck(Icons.filter_none, "Deck"),
  card(Icons.image, "Card", creatable: false),
  inventory(Icons.business_center, "Inventory", creatable: false);

  final IconData icon;
  final String label;
  final bool creatable;

  const TableObjectType(this.icon, this.label, {this.creatable = true});
}

class ContextMenuAction {
  final IconData icon;
  final bool category;
  final String label;
  final Color? color;
  final Color? iconColor;
  final bool goBack;
  final Function(TabletopController) onTap;

  const ContextMenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.category = false,
    this.goBack = true,
    this.color,
    this.iconColor,
  });
}
