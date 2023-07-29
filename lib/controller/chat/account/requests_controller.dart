import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {

  final requestsSent = <Request>[].obs;
  final requests = <Request>[].obs;

  void reset() {
    requests.clear();
  }

}

final requestsLoading = false.obs;

void newFriendRequest(String name, String tag) async {

  requestsLoading.value = true;

  final controller = Get.find<StatusController>();
  if(name == controller.name.value && tag == controller.tag.value) {
    showErrorPopup("request.self", "request.self.text");
    requestsLoading.value = false;
    return;
  }

  // Get public key and id of the user
  var res = await postRqAuth("/account/stored_actions/details", <String, dynamic>{
    "username": name,
    "tag": tag,
  }, randomRemoteID());

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return;
  }

  var json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  final id = json["account"];
  final publicKey = unpackagePublicKey(json["key"]);


  //* Prompt with confirm popup
  var declined = true;
  await showConfirmPopup(ConfirmWindow(
    title: "request.confirm.title".tr,
    text: "request.confirm.text".trParams(<String, String>{
      "name": name,
      "tag": tag,
    }),
    onConfirm: () async {
      declined = false;
      _sendFriendRequest(controller, name, tag, id, publicKey);
    },
    onDecline: () {
      declined = true;
      return false;
    },
  ));

  requestsLoading.value = !declined;
  return;
}

void _sendFriendRequest(StatusController controller, String name, String tag, String id, Uint8List publicKey) async {
  
  // Encrypt friend request
  final encryptedPayload = encryptAsymmetricAnonymous(publicKey, storedAction("fr_rq", <String, dynamic>{
    "name": controller.name.value,
    "tag": controller.tag.value,
  }));

  // Store in friends vault
  final request = Request(id, name, tag, KeyStorageV1(publicKey));
  var res = await postRqAuthorized("/account/friends/add", <String, dynamic>{
    "payload": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, request.toStoredPayload()), // Maybe use authenticated encryption here?
  });

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return;
  }

  var json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  // Send stored action
  res = await postRqAuth("/account/stored_actions/send", <String, dynamic>{
    "account": id,
    "payload": encryptedPayload,
  }, randomRemoteID());

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return;
  }

  json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  requestsLoading.value = false;
  
  return;
}

class Request {

  final String id;
  final String name;
  final String tag;
  final KeyStorage keyStorage;
  final loading = false.obs;

  Request(this.id, this.name, this.tag, this.keyStorage);
  Request.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        tag = json["tag"],
        keyStorage = KeyStorageV1.fromJson(json),
        id = json["id"];

  // Convert to a payload for the friends vault (on the server)
  String toStoredPayload() {

    final reqPayload = <String, dynamic>{
      "rq": true,
      "id": id,
      "name": name,
      "tag": tag,
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  Friend get friend => Friend(id, name, tag, keyStorage);

}