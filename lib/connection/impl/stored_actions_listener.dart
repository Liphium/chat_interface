
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

import '../../controller/current/status_controller.dart';
import '../../util/logging_framework.dart';

void setupStoredActionListener() {

  connector.listen("s_a", (event) {

    // Decrypt stored action payload
    final payload = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, event.data["payload"]);

    try {
      processStoredAction(payload);
    } catch(e) {
      sendLog("something weird happened: error while processing stored action payload");
      sendLog(e);
    }

  });

}

Future<bool> processStoredAction(String payload) async {
  
  final json = jsonDecode(payload);
  switch(json["a"]) {
    
    // Handle friend requests
    case "fr_rq":
      await _handleFriendRequestAction(json);
      break;
  }

  return true;
}

Future<bool> _handleFriendRequestAction(Map<String, dynamic> json) async {

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

  // Check signature
  final publicKey = unpackagePublicKey(resJson["key"]); 
  final statusController = Get.find<StatusController>();
  final signedMessage = "${statusController.name.value}#${statusController.tag.value}";
  if(verifySignature(publicKey, signedMessage, json["s"])) {
    sendLog("invalid friend request: invalid signature");
    return true;
  }

  // Check if the current account already sent this account a friend request (-> add friend)
  final id = resJson["account"];
  var request = Get.find<RequestController>().requestsSent.firstWhere((element) => element.id == id, orElse: () => Request.empty());

  if(request != Request.empty()) {

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

  // Add friend request to vault
  final profileKey = unpackageSymmetricKey(json["pf"]);
  request = Request(
    id,
    json["name"],
    json["tag"],
    "",
    KeyStorage(publicKey, profileKey)
  );
  res = await postRqAuthorized("/account/friends/add", <String, dynamic>{
    "payload": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, request.toStoredPayload())
  });

  if(res.statusCode != 200) {
    sendLog("couldn't store in vault: invalid request");
    return true;
  }

  resJson = jsonDecode(res.body);
  if(!resJson["success"]) {
    sendLog("couldn't store in vault: ${json["error"]}");
    return true;
  }
  
  // Add friend request
  request.vaultId = resJson["id"];
  Get.find<RequestController>().addRequest(request);

  return true;
}