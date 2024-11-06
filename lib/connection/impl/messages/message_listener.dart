import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

void setupMessageListener() {
  connector.listen("conv_msg", (event) async {
    // Get all the controllers
    final controller = Get.find<MessageController>();

    // Check if the conversation even exists on this account
    final conversation = Get.find<ConversationController>().conversations[LPHAddress.from(event.data["msg"]["conversation"])];
    if (conversation == null) {
      sendLog("invalid message, conversation not found");
      return;
    }

    // Unpack the message in a different isolate (to prevent lag)
    final message = await ConversationMessageProvider.unpackMessageInIsolate(conversation, event.data["msg"]);

    // Check if there are too many attachments
    if (message.attachments.length > 5) {
      sendLog("invalid message, more than 5 attachments");
      return;
    }

    // Tell the controller about the message
    controller.storeMessage(message, conversation);
  });
}
