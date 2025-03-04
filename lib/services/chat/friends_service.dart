import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class FriendsService {
  /// Called when the friend is updated in the vault
  static void onVaultUpdate(Friend friend) {
    if (friend.id != StatusController.ownAddress) {
      db.friend.insertOnConflictUpdate(friend.entity());
    }
    Get.find<FriendController>().addOrUpdate(friend);
  }
}
