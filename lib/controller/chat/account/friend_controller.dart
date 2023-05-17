import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';
import 'package:pointycastle/export.dart';

class FriendController extends GetxController {
  
  final friends = <String, Friend>{}.obs;

  void reset() {
    friends.clear();
  }

  void add(Friend friend) {
    friends[friend.id] = friend;
  }
}

class Friend {
  final String id;
  final String name;
  final String tag;
  final String key;
  var status = "status.offline".obs;
  var online = false.obs;

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, this.key, this.tag);
  Friend.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        key = json["key"],
        tag = json["tag"];

  FriendData get entity => FriendData(id: id, key: key, name: name, tag: tag);

  RSAPublicKey get publicKey => unpackagePublicKey(key);

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