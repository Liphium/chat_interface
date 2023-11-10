import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/status/setup/account/stored_actions_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {

  Timer? _timer;
  StatusController() {
    if(_timer != null) _timer!.cancel();

    // Update status every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if(connector.isConnected()) {
        setStatus();
      }
    });
  }

  final name = 'test'.obs;
  final tag = 'hi'.obs;
  final id = '0'.obs;

  // Status message
  final statusLoading = true.obs;
  final status = '-'.obs; // "-" = status disabled
  final type = 1.obs;

  // Shared content by friends
  final sharedContent = RxMap<String, ShareContainer>();

  // Current shared content (by this account)
  ShareContainer? _container;

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

  Future<bool> share(ShareContainer container) async {
    if(_container != null) return false;
    _container = container;
    await setStatus();
    return true;
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

    // Send space data
    var spaceData = "";
    if(_container != null) {
      spaceData = encryptSymmetric(_container!.toJson(), profileKey);
    }

    connector.sendAction(Message("st_send", <String, dynamic>{
      "status": statusPacket(newStatusJson(message ?? status.value, type ?? this.type.value)),
      "tokens": tokens,
      "data": spaceData,
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

enum ShareType {
  space
}

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
}