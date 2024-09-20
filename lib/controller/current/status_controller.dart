import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/current/steps/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {
  static String ownAccountId = "";
  static List<String> permissions = [];
  static LPHAddress get ownAddress => LPHAddress(basePath, ownAccountId);

  Timer? _timer;
  StatusController() {
    if (_timer != null) _timer!.cancel();

    // Update status every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (connector.isConnected()) {
        setStatus();
      }
    });
  }

  final displayName = "not-set".obs;
  final name = 'not-set'.obs;

  // Status message
  final statusLoading = true.obs;
  final status = ''.obs;
  final type = 1.obs;

  // Shared content by friends
  final sharedContent = RxMap<LPHAddress, ShareContainer>();

  // Current shared content (by this account)
  final ownContainer = Rx<ShareContainer?>(null);

  void setName(String value) => name.value = value;

  String statusJson() => jsonEncode(<String, dynamic>{
        "s": base64Encode(utf8.encode(status.value)),
        "t": type.value,
      });

  String newStatusJson(String status, int type) => jsonEncode(<String, dynamic>{
        "s": base64Encode(utf8.encode(status)),
        "t": type,
      });

  void fromStatusJson(String json) {
    sendLog("received $json");
    final data = jsonDecode(json);
    try {
      status.value = utf8.decode(base64Decode(data["s"]));
    } catch (e) {
      status.value = "";
    }
    type.value = data["t"] ?? 1;
  }

  String statusPacket([String? newStatusJson]) {
    return encryptSymmetric(newStatusJson ?? statusJson(), profileKey);
  }

  String sharedContentPacket() {
    if (ownContainer.value == null) {
      return "";
    }
    return encryptSymmetric(ownContainer.value!.toJson(), profileKey);
  }

  Future<bool> share(ShareContainer container) async {
    if (ownContainer.value != null) return false; // TODO: Potentially remove
    ownContainer.value = container;
    await setStatus();
    return true;
  }

  void stopSharing() {
    if (ownContainer.value == null) {
      return;
    }
    ownContainer.value = null;
    setStatus();
  }

  Future<bool> setStatus({String? message, int? type, Function()? success}) async {
    if (statusLoading.value) return false;
    statusLoading.value = true;

    // Validate the status to make sure everything is fine
    connector.sendAction(
        Message("st_validate", <String, dynamic>{
          "status": statusPacket(newStatusJson(message ?? status.value, type ?? this.type.value)),
          "data": sharedContentPacket(),
        }), handler: (event) {
      statusLoading.value = false;
      success?.call();
      if (event.data["success"] == true) {
        if (message != null) status.value = message;
        if (type != null) this.type.value = type;
        Get.find<TownsquareController>().updateEnabledState();

        // Send the new status
        subscribeToConversations(controller: this);
      }
    });

    return true;
  }

  // Log out of this account
  void logOut({deleteEverything = false, deleteFiles = false}) async {
    // Delete the session information
    db.setting.deleteWhere((tbl) => tbl.key.equals("profile"));

    // Delete all data
    if (deleteEverything) {
      for (var table in db.allTables) {
        await table.deleteAll();
      }
    }

    // Delete all files
    if (deleteFiles) {
      await Get.find<AttachmentController>().deleteAllFiles();
    }

    // Exit the app
    exit(0);
  }
}

enum ShareType { space }

abstract class ShareContainer {
  final Friend? sender;
  final ShareType type;

  ShareContainer(this.sender, this.type);

  Map<String, dynamic> toMap();

  String toJson() {
    final map = toMap();
    map["type"] = type.index;
    return jsonEncode(map);
  }

  void onDrop() {}
}
