import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

void setupStatusListener() {
  // Handle friend status change
  connector.listen("acc_st", (event) {
    final friend = handleStatus(event);
    if (friend == null) return;
    if (!friend.answerStatus) return;
    friend.answerStatus = false;

    // Send back status
    final controller = Get.find<StatusController>();
    String status = generateStatusData(
        controller.statusJson(), controller.generateFriendId());

    // Get dm with friend
    final dm = Get.find<ConversationController>()
        .conversations
        .values
        .firstWhere((element) =>
            element.members.length == 2 &&
            element.members.values
                .any((element) => element.account == friend.id));

    connector.sendAction(Message("st_res", <String, dynamic>{
      "id": dm.token.id,
      "token": dm.token.token,
      "status": status,
      "data": controller.sharedContentPacket(),
    }));
  }, afterSetup: true);

  // Don't send back when it's an answer
  connector.listen("acc_st:a", (event) {
    sendLog("received status answer");
    handleStatus(event);
  }, afterSetup: true);
}

Friend? handleStatus(Event event) {
  final message = event.data["st"] as String;
  final status = message.split(":");
  final controller = Get.find<FriendController>();

  if (status.length != 2) {
    return null;
  }

  final friend = controller.friendIdLookup[status[0]];
  if (friend == null) {
    return null;
  }

  controller.friendIdLookup[status[0]]!.loadStatus(status[1]);

  // Extract shared content
  final sharedData = event.data["d"] as String;
  if (sharedData != "") {
    sendLog("RECEIVED SHARED CONTENT");
    final sharedJson =
        decryptSymmetric(sharedData, friend.keyStorage.profileKey);
    final shared = jsonDecode(sharedJson) as Map<String, dynamic>;
    switch (ShareType.values[shared["type"] as int]) {
      // Shared space
      case ShareType.space:
        final existing = Get.find<StatusController>().sharedContent[friend.id];
        final container = SpaceConnectionContainer.fromJson(shared);
        if (existing == null || existing is! SpaceConnectionContainer) {
          Get.find<StatusController>().sharedContent[friend.id] = container;
        } else if (existing.roomId != container.roomId) {
          Get.find<StatusController>().sharedContent[friend.id] = container;
        }
        break;
    }
  } else {
    final container =
        Get.find<StatusController>().sharedContent.remove(friend.id);
    container?.onDrop();
  }

  return friend;
}
