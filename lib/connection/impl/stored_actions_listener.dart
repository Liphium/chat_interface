import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/controller/current/steps/key_setup.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/standards/unicode_string.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

import '../../controller/current/status_controller.dart';
import '../../util/logging_framework.dart';

part 'stored_actions_util.dart';

void setupStoredActionListener() {
  connector.listen("s_a", (event) async {
    try {
      await processStoredAction(event.data);
    } catch (e) {
      sendLog("something weird happened: error while processing stored action payload");
      sendLog(e);
    }
  });
}

Future<bool> processStoredAction(Map<String, dynamic> action) async {
  // Delete stored action
  final response = await deleteStoredAction(action["id"]);
  if (!response) {
    sendLog("WARNING: couldn't delete stored action, maybe other device?");
  }

  // Handle authenticated stored actions
  if (action["a"]) {
    // Decrypt payload with sequence number
    final extracted = AsymmetricSequencedInfo.extract(action["payload"]);
    if (extracted.error) {
      sendLog("ERROR: invalid format for authenticated stored action");
      return false;
    }

    // Parse the json and get the sender
    final json = jsonDecode(extracted.text);
    final address = LPHAddress.from(json["s"]);
    final sender = Get.find<FriendController>().friends[address];
    if (sender == null) {
      sendLog("ERROR: sender of authenticated stored action isn't a friend");
      return false;
    }
    if (sender.vaultId == "") {
      sendLog("ERROR: vault id of sender is not available for authenticated stored action");
      return false;
    }

    // Check if the sequence number (date) is higher than the last received
    final lastReceived = await FriendsVault.lastReceiveDate(sender.vaultId);
    if (lastReceived == null) {
      sendLog("ERROR: couldn't retrieve the last received date of sender for authenticated stored action");
      return false;
    }
    if (extracted.seq <= lastReceived.millisecondsSinceEpoch) {
      sendLog("ERROR: sequence number on authenticated stored action is out of date");
      return false;
    }

    // Verify the signature
    if (!extracted.verifySignature(sender.keyStorage.signatureKey)) {
      sendLog("ERROR: signature of authenticated stored action is invalid");
      return false;
    }

    // Update the last receive date to the latest sequence number
    final result = await FriendsVault.setReceiveDate(sender.vaultId, DateTime.fromMillisecondsSinceEpoch(extracted.seq));
    if (!result) {
      sendLog("WARNING: the last receive date couldn't be updated, this might cause future replay attacks, ignoring for now");
      return false;
    }

    switch (json["a"]) {
      // Handle conversation opening
      case "conv":
        sendLog("handling conversation opening");
        await _handleConversationOpening(action["id"], json);
        break;
      case "fr_rem":
        sendLog("handling friend deletion");
        await _handleFriendRemoval(action["id"], json);
    }

    return true;
  }

  // Handle normal stored actions
  final payload = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, action["payload"]);
  if (payload == "") {
    return true;
  }

  final json = jsonDecode(payload);
  switch (json["a"]) {
    // Handle friend requests
    case "fr_rq":
      sendLog("handling friend request");
      await _handleFriendRequestAction(action["id"], json);
      break;
  }

  return true;
}

//* Friend requests
Future<bool> _handleFriendRequestAction(String actionId, Map<String, dynamic> json) async {
  // Delete the action (it doesn't need to be handled twice)
  final response = await deleteStoredAction(actionId);
  if (!response) {
    sendLog("WARNING: couldn't delete stored action");
  }

  // Get the address from the friend request
  final address = LPHAddress.from(json["ad"]);
  if (address.id == "-") {
    sendLog("ERROR: couldn't handle friend request due to invalid address");
    return true;
  }

  // Check the signature and stuff
  final publicKey = unpackagePublicKey(json["pub"]);
  final signaturePub = unpackagePublicKey(json["sg"]);
  final statusController = Get.find<StatusController>();
  final signedMessage = statusController.name.value;
  final result = decryptAsymmetricAuth(publicKey, asymmetricKeyPair.secretKey, json["s"]);
  if (!result.success || result.message != signedMessage) {
    sendLog("invalid friend request: invalid signature");
    return true;
  }

  // Check if the current account already sent this account a friend request (-> add friend)
  final requestController = Get.find<RequestController>();
  var request = requestController.requestsSent[address];

  if (request != null) {
    // This request doesn't have the right key storage yet
    request.keyStorage.publicKey = publicKey;
    request.keyStorage.profileKeyPacked = json["pf"];
    request.keyStorage.unpackedProfileKey = unpackageSymmetricKey(json["pf"]);
    request.keyStorage.storedActionKey = json["sa"];

    // Add friend
    final controller = Get.find<FriendController>();
    await controller.addFromRequest(request);

    return true;
  }

  // Check if the request is already in the list
  if (requestController.requests[address] != null) {
    sendLog("invalid friend request: already in list");
    return true;
  }

  // Check if the guy is already a friend
  if (Get.find<FriendController>().friends.values.any((element) => element.id == address)) {
    sendLog("invalid friend request: already a friend");
    return true;
  }

  // Add friend request to vault
  final profileKey = unpackageSymmetricKey(json["pf"]);
  request = Request(
    address,
    json["name"],
    UTFString.untransform(json["dname"]),
    "",
    KeyStorage(publicKey, signaturePub, profileKey, json["sa"]),
    DateTime.now().millisecondsSinceEpoch,
  );

  final vaultId = await FriendsVault.store(request.toStoredPayload(false));
  if (vaultId == null) {
    sendLog("couldn't store in vault: something happened");
    return true;
  }

  // Add friend request
  request.vaultId = vaultId;
  Get.find<RequestController>().addRequest(request);

  return true;
}

//* Conversation opening
Future<bool> _handleConversationOpening(String actionId, Map<String, dynamic> actionJson) async {
  // Delete the action (it doesn't need to be handled twice)
  final response = await deleteStoredAction(actionId);
  if (!response) {
    sendLog("WARNING: couldn't delete stored action");
  }

  sendLog("opening conversation with ${actionJson["s"]}");
  final friend = Get.find<FriendController>().friends[LPHAddress.from(actionJson["s"])];
  if (friend == null) {
    sendLog("invalid conversation opening: friend doesn't exist");
    return true;
  }

  // Activate the token from the request
  final token = jsonDecode(actionJson["token"]);
  final json = await postNodeJSON("/conversations/activate", <String, dynamic>{"token": token});
  if (!json["success"]) {
    sendLog("couldn't activate conversation: ${json["error"]}");
    return true;
  }
  token["token"] = json["token"]; // Set new token (from activation request)

  final key = unpackageSymmetricKey(actionJson["key"]);
  final members = <Member>[];
  for (var memberData in json["members"]) {
    sendLog(memberData);
    final memberContainer = MemberContainer.decrypt(memberData["data"], key);
    members.add(Member(LPHAddress.from(memberData["id"]), memberContainer.id, MemberRole.fromValue(memberData["rank"])));
  }

  final container = ConversationContainer.decrypt(json["data"], key);
  final convToken = ConversationToken.fromJson(token);
  await Get.find<ConversationController>().addCreated(
    Conversation(
      LPHAddress.from(actionJson["id"]),
      "",
      model.ConversationType.values[json["type"]],
      convToken,
      container,
      packageSymmetricKey(key),
      0,
      DateTime.now().millisecondsSinceEpoch,
    ),
    members,
  );
  subscribeToConversation(convToken, deletions: false);

  return true;
}

//* Friend removal
Future<bool> _handleFriendRemoval(String actionId, Map<String, dynamic> actionJson) async {
  // Delete the action (it doesn't need to be handled twice)
  final response = await deleteStoredAction(actionId);
  if (!response) {
    sendLog("WARNING: couldn't delete stored action");
  }

  sendLog("deleting friend ${actionJson["s"]}");
  final friend = Get.find<FriendController>().friends[LPHAddress.from(actionJson["s"])];
  if (friend == null) {
    sendLog("invalid friend deletion: friend doesn't exist");
    return true;
  }

  // Remove the friend without asking
  return friend.remove(false.obs, removeAction: false);
}
