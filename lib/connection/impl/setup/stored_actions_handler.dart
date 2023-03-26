
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import '../../../controller/chat/friend_controller.dart';
import '../../../database/database.dart';

void handleStoredAction(String action, String target) async {
  switch(action) {

    //* Handle removed friend
    case "fr_rem":
      
      Get.find<FriendController>().friends.removeWhere((id, friend) => id == int.parse(target));
      await db.delete(db.friend).delete(FriendCompanion(id: drift.Value(int.parse(target))));

      break;

    //* Handle removed conversation
    case "conv_rem":
      
      break;

    case "conv_key":

      var args = target.split(":");
      var id = int.parse(args[0]);

      var data = await (db.select(db.conversation)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if(data == null) return;
      Conversation conv = Conversation.fromData(data);
      conv.key = decryptRSA64(args[1], asymmetricKeyPair.privateKey);
      await db.update(db.conversation).replace(conv.entity);

      Get.find<ConversationController>().conversations[id] = conv;

      break;
  }
}