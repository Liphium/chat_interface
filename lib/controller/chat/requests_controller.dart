import 'package:chat_interface/connection/connection.dart';
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

  final String name;
  final String tag;
  final int id;
  final loading = false.obs;

  Request(this.name, this.tag, this.id);
  Request.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        tag = json["tag"],
        id = json["id"];

  void accept({required Function() success}) {
    loading.value = true;

    connector.sendAction(Message("fr_rq", <String, dynamic>{
      "name": name,
      "tag": tag,
    }), waiter: () => loading.value = false);
  }

  Friend get friend => Friend(id, name, tag);

}