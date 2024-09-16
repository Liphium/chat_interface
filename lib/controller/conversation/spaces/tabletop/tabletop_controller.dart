import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_cursor.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_deck.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_text.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopController extends GetxController {
  final loading = false.obs;

  /// Currently held object
  TableObject? heldObject;
  bool movingAllowed = false;
  Offset? originalHeldObjectPosition;
  bool cancelledHolding = false;

  List<TableObject> hoveringObjects = [];
  final inventory = <CardObject>[].obs;
  final objects = <String, TableObject>{}.obs;
  final cursors = <String, TabletopCursor>{}.obs; // Other users cursors

  /// The rate at which the table is updated (to the server)
  static const tickRate = 20;
  Timer? _ticker;
  Offset? _lastMousePos;
  int inventoryHoverIndex = -1;
  Offset mousePos = const Offset(0, 0);
  Offset mousePosUnmodified = const Offset(0, 0);
  Offset globalCanvasPosition = const Offset(0, 0);

  // Position of the hint
  final hints = <String, Offset>{};

  // Movement of the canvas
  Offset canvasOffset = const Offset(0, 0);
  double canvasZoom = 0.5;
  final canvasRotation = 0.0.obs;

  /// Reset the entire state of the controller (on every call start)
  void resetControllerState() {
    loading.value = false;

    heldObject = null;
    movingAllowed = true;
    hoveringObjects.clear();
    inventory.clear();
    objects.clear();
    cursors.clear();

    _ticker?.cancel();
    _ticker = null;

    _lastMousePos = null;
    inventoryHoverIndex = -1;

    mousePos = const Offset(0, 0);
    mousePosUnmodified = const Offset(0, 0);
    globalCanvasPosition = const Offset(0, 0);

    hints.clear();

    canvasOffset = const Offset(0, 0);
    canvasZoom = 0.5;
    canvasRotation.value = 0.0;
  }

  /// Called when the tabletop tab is opened (to receive events again)
  void openTableTab() {
    spaceConnector.sendAction(
      Message("table_enable", <String, dynamic>{}),
      handler: (event) {
        sendLog("hello world");
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
  void closeTableTab() {
    objects.clear();
    _ticker?.cancel();
    hoveringObjects.clear();
    cursors.clear();
    loading.value = true;
    spaceConnector.sendAction(
      Message("table_disable", <String, dynamic>{}),
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
  void _handleTableTick() {
    // Send the location of the held object
    if (heldObject != null) {
      if (movingAllowed) {
        spaceConnector.sendAction(
          Message("tobj_move", <String, dynamic>{
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
    if (_lastMousePos != mousePos) {
      spaceConnector.sendAction(Message("tc_move", <String, dynamic>{
        "x": mousePos.dx,
        "y": mousePos.dy,
      }));
    }

    _lastMousePos = mousePos;
  }

  /// Update the cursor position of other people
  void updateCursor(String id, Offset position, double hue) {
    if (id == SpaceMemberController.ownId) {
      return;
    }

    if (cursors[id] == null) {
      cursors[id] = TabletopCursor(id, position, TabletopSettings.getCursorColor(hue: hue));
    } else {
      cursors[id]!.move(position);
    }
  }

  /// Create a new object
  TableObject newObject(TableObjectType type, String id, Offset location, Size size, double rotation, String data) {
    TableObject object;
    switch (type) {
      case TableObjectType.text:
        object = TextObject(id, location, size);
        break;
      case TableObjectType.deck:
        object = DeckObject(id, location, size);
        break;
      case TableObjectType.card:
        object = CardObject(id, location, size);
        break;
    }
    object.rotate(rotation);
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

  /// Start holding an object in tabletop (also drops objects in case they don't exist)
  void startHoldingObject(TableObject object) async {
    sendLog("should start holding");

    // Check if it is a card from the inventory that should be dropped
    var currentlyExists = false;
    if (object is CardObject && object.inventory) {
      currentlyExists = false;
      object.inventory = false;
      object.positionOverwrite = false;
      inventory.remove(object);
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
      final x = mousePos.dx - object.size.width / 2;
      final y = mousePos.dy - object.size.height / 2;
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
  void stopHoldingObject({required bool error}) {
    if (heldObject == null) return;

    // Notify the server of the unselection when there was no error
    if (!error) {
      heldObject!.unselect();
    } else {
      sendLog("error and lagback");
      // Reset the position in case it was an error
      heldObject!.location = originalHeldObjectPosition!;
      cancelledHolding = true;
    }

    // Make sure the object is no longer held
    heldObject = null;
    movingAllowed = false;
  }
}

enum TableObjectType {
  text(Icons.text_fields, "Text"),
  deck(Icons.filter_none, "Deck"),
  card(Icons.image, "Card", creatable: false);

  final IconData icon;
  final String label;
  final bool creatable;

  const TableObjectType(this.icon, this.label, {this.creatable = true});
}

abstract class TableObject {
  TableObject(this.id, this.location, this.size, this.type);

  Function()? dataCallback;
  String id;
  TableObjectType type;

  /// The size of the object
  Size size;

  /// The top left location of the object on the table
  String? dataBeforeQueue;
  DateTime? _lastMove;
  Offset? _lastLocation;
  Offset location;

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
    // TODO: handle error when rotation fails
    queue(() async {
      spaceConnector.sendAction(Message("tobj_rotate", <String, dynamic>{
        "id": id,
        "r": rot,
      }));
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
  Future<bool> sendAdd() {
    final completer = Completer<bool>();

    // Send to the server
    spaceConnector.sendAction(
      Message("tobj_create", <String, dynamic>{
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
        sendLog("ADDING $id to table");
        Get.find<TabletopController>().addObject(this);
        completer.complete(true);
      },
    );

    return completer.future;
  }

  /// Remove an object
  void sendRemove() {
    spaceConnector.sendAction(Message("tobj_delete", id));
  }

  /// Start a modification process (data)
  Future<bool> select() {
    final completer = Completer<bool>();

    spaceConnector.sendAction(
      Message("tobj_select", id),
      handler: (event) {
        if (!event.data["success"]) {
          showErrorPopup("error", event.data["message"]);
          sendLog("can't modify rn");
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

    spaceConnector.sendAction(
      Message("tobj_unselect", id),
      handler: (event) {
        if (!event.data["success"]) {
          sendLog("can't modify rn");
          completer.complete(false);
          return;
        }
        completer.complete(true);
      },
    );

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
    spaceConnector.sendAction(
      Message("tobj_mqueue", id),
      handler: (event) {
        if (!event.data["success"]) {
          showErrorPopup("error", event.data["message"]);
          return;
        }

        sendLog(event.data);

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
    spaceConnector.sendAction(
      Message("tobj_modify", <String, dynamic>{
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
