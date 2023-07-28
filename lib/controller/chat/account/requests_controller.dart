import 'dart:typed_data';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:get/get.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {

  final requests = <Request>[].obs;

  void reset() {
    requests.clear();
  }

}

class Request {

  final String id;
  final String name;
  final String tag;
  final Uint8List publicKey;
  final Uint8List friendKey;
  final loading = false.obs;

  Request(this.id, this.name, this.tag, this.publicKey, this.friendKey);
  Request.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        tag = json["tag"],
        publicKey = unpackagePublicKey(json["publicKey"]),
        friendKey = unpackagePublicKey(json["friendKey"]),
        id = json["id"];

  void accept({required Function() success}) {
    loading.value = true;

    connector.sendAction(Message("fr_rq", <String, dynamic>{
      "name": name,
      "tag": tag,
    }), waiter: () => loading.value = false);
  }

  Friend get friend => Friend(id, name, tag, publicKey, friendKey);

}