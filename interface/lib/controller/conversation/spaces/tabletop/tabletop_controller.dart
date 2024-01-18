import 'dart:ui';

import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_square.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';

class TabletopController extends GetxController {
  final loading = false.obs;
  final enabled = false.obs;

  final objects = <TableObject>[].obs;

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
      },
    );
  }

  /// Leave the tabletop session
  void disconnect({bool leave = true}) {
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

  /// Add a new object
  void addObject(TableObjectType type, String data) {
    TableObject object;
    switch (type) {
      case TableObjectType.square:
        object = SquareObject("", const Offset(0, 0), const Size(100, 100), type);
        break;
    }

    // Send to the server
    spaceConnector.sendAction(Message("tobj_create", <String, dynamic>{
      "type": type.index,
      "data": object.getData(),
    }));
  }

  /// Remove an object
  void removeObject(TableObject object) {
    spaceConnector.sendAction(Message("tobj_remove", <String, dynamic>{
      "id": object.id,
    }));
  }
}

enum TableObjectType { square }

abstract class TableObject {
  final String id;
  TableObjectType type;

  /// The top left location of the object on the table
  Offset location;

  /// The size of the object
  Size size;

  TableObject(this.id, this.location, this.size, this.type);

  /// Required when getData is implemented
  void importData(String data) {}

  /// Implemented optionally when needed
  String getData() {
    return "";
  }

  /// Render without rotation and scale applied (used for UI)
  void renderUI(Canvas canvas) {}

  /// Render with rotation and scale applied (used for movable objects)
  void render(Canvas canvas) {}
}
