import 'dart:async';

import 'package:chat_interface/controller/spaces/tabletop/tabletop_cursor.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_card.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_inventory.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals.dart';

class TabletopController {
  static final loading = signal(false);

  /// Currently held object
  static TableObject? heldObject;
  static bool movingAllowed = false;
  static Offset? originalHeldObjectPosition;
  static bool cancelledHolding = false;

  static List<TableObject> hoveringObjects = [];
  static InventoryObject? inventory;
  static final orderSorted = <int>[];
  static final objectOrder = <int, String>{};
  static final objects = <String, TableObject>{};
  static final cursors = mapSignal(<String, TabletopCursor>{}); // Other users cursors

  /// The rate at which the table is updated (to the server)
  static const tickRate = 20;
  static Timer? _ticker;
  static Offset? _lastMousePos;
  static Offset mousePos = const Offset(0, 0);
  static Offset mousePosUnmodified = const Offset(0, 0);
  static Offset globalCanvasPosition = const Offset(0, 0);

  // Developer options
  static final disableCursorSending = signal(false);

  // Movement of the canvas
  static Offset canvasOffset = const Offset(0, 0);
  static double canvasZoom = 0.5;
  static final canvasRotation = 0.0.obs;

  /// Reset the entire state of the controller (on every call start)
  static void resetControllerState() {
    loading.value = false;

    heldObject = null;
    movingAllowed = true;
    hoveringObjects.clear();
    inventory = null;
    objects.clear();
    objectOrder.clear();
    cursors.clear();

    _ticker?.cancel();
    _ticker = null;

    _lastMousePos = null;

    mousePos = const Offset(0, 0);
    mousePosUnmodified = const Offset(0, 0);
    globalCanvasPosition = const Offset(0, 0);

    canvasOffset = const Offset(0, 0);
    canvasZoom = 0.5;
    canvasRotation.value = 0.0;
  }

  /// Called when the tabletop tab is opened (to receive events again)
  static void openTableTab() {
    loading.value = true;
    SpaceConnection.spaceConnector!.sendAction(
      ServerAction("table_enable", <String, dynamic>{}),
      handler: (event) {
        loading.value = false;

        if (!event.data["success"]) {
          showErrorPopup("error", "server.error".tr);
          return;
        }
        sendLog("success");

        _ticker = Timer.periodic(const Duration(milliseconds: 1000 ~/ tickRate), (timer) {
          _handleTableTick();
        });
      },
    );
  }

  /// Called when the tabletop tab is closed (to disable events)
  static void closeTableTab() {
    objects.clear();
    objectOrder.clear();
    _ticker?.cancel();
    hoveringObjects.clear();
    cursors.clear();
    loading.value = true;
    SpaceConnection.spaceConnector!.sendAction(
      ServerAction("table_disable", <String, dynamic>{}),
      handler: (event) {
        loading.value = false;

        if (!event.data["success"]) {
          showErrorPopup("error", "server.error".tr);
          return;
        }
      },
    );
  }

  /// Called every tick
  static void _handleTableTick() {
    // Send the location of the held object
    if (heldObject != null) {
      if (movingAllowed) {
        SpaceConnection.spaceConnector!.sendAction(
          ServerAction("tobj_move", <String, dynamic>{
            "id": heldObject!.id,
            "x": heldObject!.location.dx,
            "y": heldObject!.location.dy,
          }),
          handler: (event) {
            if (!event.data["success"]) {
              sendLog("movement not successful");
              stopHoldingObject(error: true);
            }
          },
        );
      }
    }

    // Send mouse position if available
    if (_lastMousePos != mousePos && !disableCursorSending.value) {
      SpaceConnection.spaceConnector!.sendAction(ServerAction("tc_move", <String, dynamic>{
        "x": mousePos.dx,
        "y": mousePos.dy,
        "c": TabletopSettings.getHue(),
      }));
    }

    _lastMousePos = mousePos;
  }

  /// Update the cursor position of other people
  static void updateCursor(String id, Offset position, double hue) {
    if (id == SpaceMemberController.getOwnId()) {
      return;
    }
    batch(() {
      if (cursors.value[id] == null) {
        cursors.value[id] = TabletopCursor(id, position, hue);
      } else {
        if (cursors.value[id]!.hue.value != hue) {
          cursors.value[id]!.hue.value = hue;
        }
        cursors.value[id]!.move(position);
      }
    });
  }

  /// Add an object to the list
  static void addObject(TableObject object) {
    if (object.id == "" || object.order == 0) {
      return;
    }

    // Insert the object
    addNewOrder(object.order);
    objectOrder[object.order] = object.id;
    objects[object.id] = object;

    // Set as inventory if it has the same id
    if (object.id == inventory?.id) {
      inventory = object as InventoryObject;
    }
  }

  /// Add a new order to the sorted order list.
  static void addNewOrder(int newOrder) {
    int index = 0;
    for (var order in orderSorted) {
      if (newOrder < order) {
        break;
      }
      index++;
    }
    orderSorted.insert(index, newOrder);
  }

  /// Remove an object from the list
  static void removeObject({TableObject? object, String? id}) {
    objects.remove(id ?? object?.id);
    if (objectOrder[object?.order ?? -1] != null) {
      objectOrder.remove(object?.order);
    }
  }

  /// Set the order of an object
  static void setOrder(String object, int newOrder, {bool removeOld = false}) {
    // Remove the object id from the old layer if desired by the server
    if (newOrder == -1) {
      final obj = objects[object]!;
      objectOrder.remove(obj.order);
      orderSorted.remove(obj.order);
      return;
    }

    // Remove the old order
    final obj = objects[object];
    if (obj != null) {
      objectOrder.remove(obj.order);
      orderSorted.remove(obj.order);
    }

    // Set the new order of the object
    addNewOrder(newOrder);
    objectOrder[newOrder] = object;
    objects[object]!.order = newOrder;
  }

  /// Get the object at a location
  static List<TableObject> raycast(Offset location) {
    final objectsFound = <TableObject>[];
    final typesFound = <TableObjectType>[];
    final ordersToRemove = <int>[];
    for (var order in orderSorted.reversed) {
      // Get the object at the current drawing layer
      final objectId = objectOrder[order];
      if (objectId == null) {
        continue;
      }

      // Check if the object is hovered
      final object = objects[objectId];
      if (object == null) {
        ordersToRemove.add(order);
        continue;
      }
      final rect = Rect.fromLTWH(object.location.dx, object.location.dy, object.size.width, object.size.height);
      if (rect.contains(location) && !typesFound.contains(object.type)) {
        objectsFound.add(object);
        typesFound.add(object.type);
      }
    }

    // Remove all of the orders that have to be removed
    for (var order in ordersToRemove) {
      objectOrder.remove(order);
      orderSorted.remove(order);
    }

    return objectsFound;
  }

  /// Start holding an object in tabletop (also drops objects in case they don't exist)
  static Future<void> startHoldingObject(TableObject object) async {
    // Check if it is a card from the inventory that should be dropped
    var currentlyExists = false;
    if (object is CardObject && object.inventory) {
      currentlyExists = false;
      object.inventory = false;
      object.positionOverwrite = false;
      inventory?.remove(object);
    } else {
      currentlyExists = objects.containsKey(object.id);
    }

    // Set all the variables to start the object holding
    originalHeldObjectPosition = object.location;
    heldObject = object;
    cancelledHolding = false;
    movingAllowed = false;

    // add the object to the table if it doesn't exist
    if (!currentlyExists) {
      // Give it a start location
      final now = DateTime.now();
      final x = object.positionX.value(now);
      final y = object.positionY.value(now);
      object.location = Offset(x, y);

      // Add the object to the table
      final result = await object.sendAdd();
      if (!result) {
        sendLog("FAILED TO ADD");
        // Delete the object and make sure it's gone
        if (heldObject == object) {
          heldObject = null;
        }
        objects.remove(object.id);
        return;
      }
    }

    // Select the object
    final success = await object.select();
    if (!success) {
      showErrorPopup("error", "tabletop.object_already_held".tr);
      stopHoldingObject(error: true);
      return;
    }

    // Allow dragging of the object
    movingAllowed = true;
  }

  /// Cancels the holding of an object and makes sure it's cancelled
  static void stopHoldingObject({required bool error}) {
    if (heldObject == null) return;

    // Notify the server of the unselection when there was no error
    heldObject!.unselect();
    if (error) {
      sendLog("error and lagback");
      // Reset the position in case it was an error
      heldObject!.location = originalHeldObjectPosition!;
      cancelledHolding = true;
    }

    // Make sure the object is no longer held
    heldObject = null;
    movingAllowed = false;
  }

  /// Gets the inventory or creates it on the table (in case needed).
  static Future<InventoryObject?> getOrCreateInventory() async {
    if (inventory == null) {
      final object = InventoryObject("", -1, mousePos, Size(200, 200));
      if (await object.sendAdd()) {
        inventory = object;
      } else {
        sendLog("couldn't create inventory, something went wrong");
      }
    }

    return inventory;
  }
}

class AnimatedDouble {
  static const animationDuration = 250;
  static const curve = Curves.ease;

  final int duration;
  DateTime _start = DateTime.now();

  double lastValue = 0;
  late double _value;

  AnimatedDouble(double value, {double from = 0.0, this.duration = animationDuration}) {
    _value = from;
    setValue(value, from: from);
  }

  void setValue(double newValue, {double? from}) {
    if (_value == newValue) return;
    final now = DateTime.now();
    lastValue = from ?? value(now);
    _start = now;
    _value = newValue;
  }

  void setRealValue(double realValue) {
    setValue(realValue, from: realValue);
  }

  // Get an interpolated value
  double value(DateTime now) {
    final timeDifference = now.millisecondsSinceEpoch - _start.millisecondsSinceEpoch;
    return lastValue + (_value - lastValue) * curve.transform(clampDouble(timeDifference / duration, 0, 1));
  }

  get realValue => _value;
}
