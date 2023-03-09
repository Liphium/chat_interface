import 'package:get/get.dart';

class FriendController extends GetxController {
  
  final friends = <Friend>[].obs;

}

class Friend {
  final int id;
  final String name;
  final String tag;
  var status = "".obs;
  var online = false.obs;

  Friend(this.id, this.name, this.tag);
  Friend.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        tag = json["tag"];
}