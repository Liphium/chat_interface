import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/chat/conversation/member_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:get/get.dart';

import '../../../util/snackbar.dart';

// Action: conv_open:l
void conversationOpen(Event event) async {

  if(!event.data["success"]) {
    showMessage(SnackbarType.error, "conv.${event.data["message"]}".tr);
  } else {

    // Grab conversation data
    String conversationName = event.data["conversation"]["data"];
    int conversationId = event.data["conversation"]["id"];
    String key = decryptRSA64(event.data["key"], asymmetricKeyPair.privateKey);

    // Show message
    showMessage(SnackbarType.info, "conv.opened".trParams(<String, String>{
      "name": conversationName,
    }));

    // Add to database
    ConversationData data;
    await db.into(db.conversation).insert(data = ConversationData(
      id: conversationId,
      key: key,
      data: conversationName,
      updatedAt: BigInt.from(DateTime.now().millisecondsSinceEpoch),      
    ));

    FriendController controller = Get.find();

    // Add members to database
    for (var member in event.data["members"]) {
    
      String name = (controller.friends[member["account"]] ?? Friend(0, "fj-${member["account"]}", "", "tag")).name;
      final mem = Member.fromJson(name, member);
      await db.into(db.member).insertOnConflictUpdate(mem.toData(member["id"], conversationId));
    }

    // Add to UI
    Get.find<ConversationController>().add(Conversation.fromData(data));
  }

}

// Action: conv_open
void conversationOpenStatus(Event event) async {

  if(!event.data["success"]) {
    showMessage(SnackbarType.error, "conv.${event.data["message"]}".tr);
  }

}