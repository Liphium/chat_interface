import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/database/database.dart';
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

    // Show message
    showMessage(SnackbarType.info, "conv.opened".trParams(<String, String>{
      "name": conversationName,
    }));

    // Add to UI
    Get.find<ConversationController>().conversations.add(Conversation.fromJson(event.data["conversation"]));

    // Add to database
    await db.into(db.conversation).insert(ConversationData(
      id: conversationId,
      data: conversationName,
      updatedAt: BigInt.from(DateTime.now().millisecondsSinceEpoch),      
    ));

  }

}

// Action: conv_open
void conversationOpenStatus(Event event) async {

  if(!event.data["success"]) {
    showMessage(SnackbarType.error, "conv.${event.data["message"]}".tr);
  } else {
    showMessage(SnackbarType.success, "conv.created");
  }

}