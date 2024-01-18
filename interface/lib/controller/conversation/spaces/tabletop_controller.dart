import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';

class TabletopController extends GetxController {
  final loading = false.obs;
  final enabled = false.obs;

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
}

enum TableObjectType { card, stack, image }

abstract class TableObject {
  TableObjectType type;
  Location location;

  TableObject(this.location, this.type);
}

class Location {
  final double x;
  final double y;

  Location(this.x, this.y);

  Location operator +(Location other) {
    return Location(x + other.x, y + other.y);
  }

  Location operator -(Location other) {
    return Location(x - other.x, y - other.y);
  }

  Location operator *(double other) {
    return Location(x * other, y * other);
  }

  Location operator /(double other) {
    return Location(x / other, y / other);
  }
}
