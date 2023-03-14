import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';

import '../../database/database.dart';

class FriendController extends GetxController {
  
  final friends = <Friend>[].obs;

  void reset() {
    friends.clear();
  }

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

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, this.tag);
  Friend.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        tag = json["tag"];

  FriendData get entity => FriendData(id: id, name: name, tag: tag);

  //* Remove friend
  void remove(RxBool loading) {
    loading.value = true;

    // Send action to server
    connector.sendAction(Message("fr_rem", <String, dynamic>{
      "id": id,
    }), handler: (event) async {
      loading.value = false;

      if(event.data["success"] as bool) {
        
        // Remove from database
        await db.delete(db.friend).delete(entity);
        Get.find<FriendController>().friends.remove(this);

        showMessage(SnackbarType.success, "friends.removed".trParams({"name": name}));
      } else {
        showMessage(SnackbarType.error, (event.data["message"] as String).tr);
      }
    });
  }
}