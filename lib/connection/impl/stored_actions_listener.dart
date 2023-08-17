
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

import '../../controller/current/status_controller.dart';
import '../../util/logging_framework.dart';

void setupStoredActionListener() {

  connector.listen("s_a", (event) async {

    try {
      await processStoredAction(event.data);
    } catch(e) {
      sendLog("something weird happened: error while processing stored action payload");
      sendLog(e);
    }

  });

}

Future<bool> processStoredAction(Map<String, dynamic> action) async {
  
  // Decrypt stored action payload
  final payload = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, action["payload"]);

  final json = jsonDecode(payload);
  switch(json["a"]) {
    
    // Handle friend requests
    case "fr_rq":
      await _handleFriendRequestAction(action["id"], json);
      break;
  }

  return true;
}

Future<bool> _handleFriendRequestAction(String actionId, Map<String, dynamic> json) async {
  
  // Delete the action (it doesn't need to be handled twice)
  await deleteStoredAction(actionId);

  // Get friend by name and tag
  var res = await postRqAuth("/account/stored_actions/details", {
    "username": json["name"],
    "tag": json["tag"]
  }, randomRemoteID());

  if(res.statusCode != 200) {
    sendLog("invalid friend request: invalid request");
    return true;
  }

  var resJson = jsonDecode(res.body);
  if(!resJson["success"]) {
    sendLog("invalid friend request: ${json["error"]}");
    return true;
  }

  // Check "signature"
  final publicKey = unpackagePublicKey(resJson["key"]); 
  final statusController = Get.find<StatusController>();
  final signedMessage = "${statusController.name.value}#${statusController.tag.value}";
  final result = decryptAsymmetricAuth(publicKey, asymmetricKeyPair.secretKey, json["s"]);
  if(!result.success || result.message != signedMessage) {
    sendLog("invalid friend request: invalid signature");
    return true;
  }

  // Check if the current account already sent this account a friend request (-> add friend)
  final id = resJson["account"];
  var request = Get.find<RequestController>().requestsSent.firstWhere((element) => element.id == id, orElse: () => Request.mock("hi"));
  sendLog("${request.id} | $id");

  if(request.id != "hi") {

    // Add friend
    final controller = Get.find<FriendController>();
    controller.addFromRequest(request);

    return true;
  }

  // Check if the request is already in the list
  if(Get.find<RequestController>().requests.any((element) => element.id == id)) {
    sendLog("invalid friend request: already in list");
    return true;
  }

  // Check if the guy is already a friend
  if(Get.find<FriendController>().friends.values.any((element) => element.id == id)) {
    sendLog("invalid friend request: already a friend");
    return true;
  }

  // Add friend request to vault
  final profileKey = unpackageSymmetricKey(json["pf"]);
  request = Request(
    id,
    json["name"],
    json["tag"],
    "",
    actionId,
    KeyStorage(publicKey, profileKey)
  );

  final vaultId = await storeInFriendsVault(request.toStoredPayload(false));
  if(vaultId == null) {
    sendLog("couldn't store in vault: something happened");
    return true;
  }

  // Add friend request
  request.vaultId = vaultId;
  Get.find<RequestController>().addRequest(request);

  return true;
}

Future<bool> deleteStoredAction(String id) async {
  
  final res = await postRqAuthorized("/account/stored_actions/delete", {
    "id": id
  });

  if(res.statusCode != 200) {
    sendLog("couldn't delete stored action: invalid request");
    return false;
  }

  final json = jsonDecode(res.body);
  if(!json["success"]) {
    sendLog("couldn't delete stored action: ${json["error"]}");
    return false;
  }

  return true;
}