import 'dart:typed_data';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';

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
  String id;
  String name;
  String tag;
  Uint8List publicKey;
  Uint8List friendKey;
  var status = "-".obs;
  final statusType = 0.obs;

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, this.tag, this.publicKey, this.friendKey);

  Friend.system() : id = "system", name = "System", tag = "fjc", publicKey = Uint8List(0), friendKey = Uint8List(0);
  Friend.me()
        : id = '',
          name = '',
          tag = '',
          publicKey = Uint8List(0),
          friendKey = Uint8List(0) {
    final StatusController controller = Get.find();
    id = controller.id.value;
    name = controller.name.value;
    tag = controller.tag.value;
  }
  Friend.unknown(this.id) 
        : name = 'fj-$id',
          tag = 'tag',
          publicKey = Uint8List(0),
          friendKey = Uint8List(0);

  //* Remove friend
  void remove(RxBool loading) {
    loading.value = true;

    // Send action to server
    connector.sendAction(Message("fr_rem", <String, dynamic>{
      "id": id,
    }), handler: (event) async {
      loading.value = false;

      if(event.data["success"] as bool) {
        
        // Remove from database TODO: Reimplement
        //await db.delete(db.friend).delete(entity);
        Get.find<FriendController>().friends.remove(this);

        showMessage(SnackbarType.success, "friends.removed".trParams({"name": name}));
      } else {
        showMessage(SnackbarType.error, (event.data["message"] as String).tr);
      }
    });
  }
}