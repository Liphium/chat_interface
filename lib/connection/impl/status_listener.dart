import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
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
    String status = generateStatusData(controller.statusJson());

    // Get dm with friend
    final dm = Get.find<ConversationController>()
        .conversations
        .values
        .firstWhere((element) => element.members.length == 2 && element.members.values.any((element) => element.account == friend.id));

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

  // Receive status changes from other devices
  connector.listen("acc_st:o", (event) {
    sendLog("received status change from other device");
    handleStatus(event);
  }, afterSetup: true);
}

Friend? handleStatus(Event event) {
  final convId = event.data["c"] as String;
  final owner = event.data["o"] as String;
  final message = event.data["st"] as String;
  final controller = Get.find<FriendController>();

  // Load own status (if it's sent by the same account)
  if (owner == StatusController.ownAccountId) {
    controller.friends[owner]!.loadStatus(message);
    Get.find<StatusController>().fromStatusJson(decryptSymmetric(message, profileKey));
    return null;
  }

  // Get conversation from the status packet
  final convController = Get.find<ConversationController>();
  final conversation = convController.conversations[convId];
  if (conversation == null) {
    sendLog("conversation not found for status packet $convId");
    return null;
  }

  // Get the account id of the person sending the status packet
  final member = conversation.members.values.firstWhere((mem) => mem.tokenId == owner, orElse: () => Member("", "", MemberRole.user));
  if (member.tokenId == "") {
    sendLog("member $owner not found in conversation $convId (status packet)");
    return null;
  }
  final friend = controller.friends[member.account];
  if (friend == null) {
    sendLog("account ${member.account} isn't a friend (status packet)");
    return null;
  }

  // Load the status
  friend.loadStatus(message);

  // Extract shared content
  final sharedData = event.data["d"] as String;
  if (sharedData != "") {
    sendLog("RECEIVED SHARED CONTENT");
    final sharedJson = decryptSymmetric(sharedData, friend.keyStorage.profileKey);
    sendLog(sharedJson);
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
    final container = Get.find<StatusController>().sharedContent.remove(friend.id);
    container?.onDrop();
  }

  return friend;
}
