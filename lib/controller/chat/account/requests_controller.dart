import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:get/get.dart';
import 'package:pointycastle/export.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {

  final requests = <Request>[].obs;

  void reset() {
    requests.clear();
  }

}

class Request {

  final String name;
  final String tag;
  final String key;
  final String id;
  final loading = false.obs;

  Request(this.name, this.tag, this.key, this.id);
  Request.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        tag = json["tag"],
        key = json["key"],
        id = json["id"];

  void accept({required Function() success}) {
    loading.value = true;

    connector.sendAction(Message("fr_rq", <String, dynamic>{
      "name": name,
      "tag": tag,
    }), waiter: () => loading.value = false);
  }

  Friend get friend => Friend(id, name, key, tag);

  RSAPublicKey get publicKey => unpackagePublicKey(key);

}