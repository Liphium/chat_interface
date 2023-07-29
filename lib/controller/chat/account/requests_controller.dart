import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {

  final requests = <Request>[].obs;

  void reset() {
    requests.clear();
  }

}

final requestsLoading = false.obs;

Future<Request?> newFriendRequest(String name, String tag) async {

  requestsLoading.value = true;

  final controller = Get.find<StatusController>();
  if(name == controller.name.value && tag == controller.tag.value) {
    showErrorPopup("request.self", "request.self.text");
    requestsLoading.value = false;
    return null;
  }

  // Get public key and id of the user
  var res = await postRqAuth("/account/stored_actions/details", <String, dynamic>{
    "username": name,
    "tag": tag,
  }, randomRemoteID());

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return null;
  }

  var json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return null;
  }

  final id = json["account"];
  final publicKey = unpackagePublicKey(json["key"]);

  // Encrypt friend request
  final encryptedPayload = encryptAsymmetricAnonymous(publicKey, jsonEncode(<String, dynamic>{
    "username": controller.name.value,
    "tag": controller.tag.value,
  }));

  // Send stored action
  res = await postRqAuth("/account/stored_actions/send", <String, dynamic>{
    "account": id,
    "payload": encryptedPayload,
  }, randomRemoteID());

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return null;
  }

  json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return null;
  }



  requestsLoading.value = false;

  return null;
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

  void accept({required Function() success}) {
    loading.value = true;

    connector.sendAction(Message("fr_rq", <String, dynamic>{
      "name": name,
      "tag": tag,
    }), waiter: () => loading.value = false);
  }

  Friend get friend => Friend(id, name, tag, keyStorage);

}