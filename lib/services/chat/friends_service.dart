import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as dbe;
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/connection/chat/stored_actions_listener.dart';
import 'package:chat_interface/util/web.dart';
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

  /// Remove a friend.
  ///
  /// Returns an error if there was one.
  static Future<String?> remove(Friend friend, {bool removeAction = false}) async {
    // Remove the friends vault
    final error = await FriendsVault.remove(friend.vaultId);
    if (error != null) {
      return error;
    }

    // Send the deletion stored action in case necessary
    if (removeAction) {
      final error = await sendAuthenticatedStoredAction(friend, authenticatedStoredAction("fr_rem", {}));
      if (error != null) {
        return error;
      }
    }

    // Leave direct message conversations with the guy in them
    var toRemove = <LPHAddress>[];
    for (var conversation in ConversationController.conversations.values) {
      if (conversation.members.values.any((mem) => mem.address == friend.id) && conversation.type == dbe.ConversationType.directMessage) {
        toRemove.add(conversation.id);
      }
    }
    for (var key in toRemove) {
      await ConversationService.delete(key);
    }

    return null;
  }
}
