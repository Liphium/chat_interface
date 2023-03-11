import 'package:get/get.dart';

import '../../database/database.dart';

class FriendController extends GetxController {
  
  final friends = <Friend>[].obs;

  void insert(Friend friend) async {
    await db.into(db.friend).insertOnConflictUpdate(friend.entity);
  }
}

class Friend {
  final int id;
  final String name;
  final String tag;
  var status = "test.status".obs;
  var online = false.obs;

  Friend(this.id, this.name, this.tag);
  Friend.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        tag = json["tag"];

  FriendData get entity => FriendData(id: id, name: name, tag: tag);
}