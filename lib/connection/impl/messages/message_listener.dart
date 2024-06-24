import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

void setupMessageListener() {
  connector.listen("conv_msg", (event) {
    // Decrypt message
    final convController = Get.find<ConversationController>();
    final controller = Get.find<MessageController>();
    if (convController.conversations[event.data["msg"]["conversation"]] == null) {
      sendLog("invalid message, conversation not found");
      return;
    }
    final message = Message.fromJson(event.data["msg"]);
    sendLog("MESSAGE SENT");

    if (message.attachments.length > 5) {
      sendLog("invalid message, more than 5 attachments");
      return;
    }

    controller.storeMessage(message);
  });
}
