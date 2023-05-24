
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import '../../../database/database.dart';

void handleStoredAction(String action, String target) async {
  
  switch(action) {

    //* Handle removed friend
    case "fr_rem":
      
      Get.find<FriendController>().friends.removeWhere((id, friend) => id == target);
      await db.delete(db.friend).delete(FriendCompanion(id: drift.Value(target)));

      break;

    //* Handle removed conversation
    case "conv_rem":
      
      break;

    case "conv_key":

      logger.i("CONVERSATION KEY");

      var args = target.split(":");
      var id = args[0];

      ConversationController controller = Get.find();
      var data = await (db.select(db.conversation)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      // Decrypt key
      Conversation conv = Conversation.fromData(data ?? ConversationData(id: "0", data: "unknown", key: "key", updatedAt: BigInt.from(DateTime.now().millisecondsSinceEpoch)));
      conv.key = decryptRSA64(args[1], asymmetricKeyPair.privateKey);

      // Update conversation
      Conversation conversation = controller.conversations[id] ?? conv;

      conversation.key = conv.key;
      conversation.refreshName(Get.find<StatusController>(), Get.find<FriendController>());
      conv = conversation;

      // Insert into database
      controller.conversations[id] = conversation;
      await db.into(db.conversation).insertOnConflictUpdate(ConversationCompanion(
        id: drift.Value(id), 
        key: drift.Value(conv.key), 
        data: const drift.Value.absent(),
        updatedAt: drift.Value(BigInt.from(DateTime.now().millisecondsSinceEpoch))
      ));

      break;
  }
}