
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

void setupStoredActionListener() {

  connector.listen("s_a", (event) {

    // Decrypt stored action payload
    final payload = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, event.data["payload"]);

    try {
      processStoredAction(payload);
    } catch(e) {
      print("something weird happened: error while processing stored action payload");
      print(e);
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
  final res = await postRqAuth("/account/stored_actions/details", {
    "username": json["name"],
    "tag": json["tag"]
  }, randomRemoteID());

  if(res.statusCode != 200) {
    print("invalid friend request: invalid request");
    return true;
  }

  final resJson = jsonDecode(res.body);
  if(!resJson["success"]) {
    print("invalid friend request: ${json["error"]}");
    return true;
  }

  // Check if the current account already sent this account a friend request (-> add friend)
  final id = resJson["account"];
  final request = Get.find<RequestController>().requestsSent.firstWhere((element) => element.id == id, orElse: () => Request.empty());

  if(request != Request.empty()) {

    // Add friend
    final controller = Get.find<FriendController>();
    controller.add(request.friend);

    return true;
  }

  // Check if the request is already in the list
  if(Get.find<RequestController>().requests.any((element) => element.id == id)) {
    print("invalid friend request: already in list");
    return true;
  }

  // Add friend request
  Get.find<RequestController>().addRequest(Request(
    id,
    json["name"],
    json["tag"],
    KeyStorageV1(unpackagePublicKey(resJson["key"]))
  ));

  return true;
}