import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/status/setup/account/stored_actions_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {

  StatusController() {
    sendLog("CONSTRUCTED STATUS CONTROLLER");
  }

  final name = 'test'.obs;
  final tag = 'hi'.obs;
  final id = '0'.obs;

  // Status message
  final statusLoading = true.obs;
  final status = '-'.obs; // "-" = status disabled
  final type = 1.obs;

  void setName(String value) => name.value = value;
  void setTag(String value) => tag.value = value;
  void setId(String value) => id.value = value;

  String statusJson() => jsonEncode(<String, dynamic>{
    "s": status.value,
    "t": type.value,
  });

  String newStatusJson(String status, int type) => jsonEncode(<String, dynamic>{
    "s": status,
    "t": type,
  });

  void fromStatusJson(String json) {
    final data = jsonDecode(json);
    status.value = data["s"];
    type.value = data["t"];
  }

  String generateFriendId() {
    return hashSha(id.value + name.value + tag.value + storedActionKey);
  }

  String statusPacket(String statusJson) {
    return "${generateFriendId()}:${encryptSymmetric(statusJson, profileKey)}";
  }

  Future<bool> setStatus({String? message, int? type, Function()? success}) async {
    if(statusLoading.value) return false;
    statusLoading.value = true;

    final tokens = <Map<String, dynamic>>[];
    for(var conversation in Get.find<ConversationController>().conversations.values) {
      if(conversation.members.length == 2) {
        tokens.add(conversation.token.toMap());
      }
    }

    connector.sendAction(Message("st_send", <String, dynamic>{
      "status": statusPacket(newStatusJson(message ?? status.value, type ?? this.type.value)),
      "tokens": tokens,
    }), handler: (event) {
      statusLoading.value = false;
      success?.call();
      if(event.data["success"] == true) {
        if(message != null) status.value = message;
        if(type != null) this.type.value = type;
      }
    });

    return true;
  }

}

String friendId(Friend friend) {
  return hashSha(friend.id + friend.name + friend.tag + friend.keyStorage.storedActionKey);
}