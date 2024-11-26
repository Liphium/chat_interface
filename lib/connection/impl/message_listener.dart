import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

void setupMessageListener() {
  // Listen for one message
  connector.listen("conv_msg", (event) async {
    // Check if the conversation even exists on this account
    final conversation = Get.find<ConversationController>().conversations[LPHAddress.from(event.data["msg"]["conversation"])];
    if (conversation == null) {
      sendLog("WARNING: invalid message, conversation not found");
      return;
    }

    // Unpack the message in a different isolate (to prevent lag)
    final message = await ConversationMessageProvider.unpackMessageInIsolate(conversation, event.data["msg"]);

    // Check if there are too many attachments
    if (message.attachments.length > 5) {
      sendLog("WARNING: invalid message, more than 5 attachments");
      return;
    }

    // Tell the controller about the message
    Get.find<MessageController>().storeMessage(message, conversation);
  });

  // Listen for multiple messages (mp stands for multiple)
  connector.listen(
    "conv_msg_mp",
    (event) async {
      // Check if the conversation even exists on this account
      final conversation = Get.find<ConversationController>().conversations[LPHAddress.from(event.data["conv"])];
      if (conversation == null) {
        sendLog("WARNING: invalid message, conversation not found");
        return;
      }

      // Unpack all of the messages in an isolate
      final messages = await ConversationMessageProvider.unpackMessagesInIsolate(conversation, event.data["msgs"]);

      // Remove all messages with more than 5 attachments
      messages.removeWhere((msg) {
        if (msg.attachments.length > 5) {
          sendLog("WARNING: invalid message received, dropping it (attachments > 5)");
          return true;
        }

        return false;
      });

      // Store all of the messages in the local database
      Get.find<MessageController>().storeMessages(messages, conversation);
    },
  );
}
