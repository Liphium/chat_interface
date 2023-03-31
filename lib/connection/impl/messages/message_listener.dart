import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/impl/messages/typing_listener.dart';
import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:get/get.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;

import 'conversation_listener.dart';

void setupMessageListeners() {
  connector.listen("conv_open:l", conversationOpen);
  connector.listen("conv_open", conversationOpenStatus);
  connector.listen("conv_msg", message);

  // Typing status
  connector.listen("conv_t", typingStatus);
  connector.listen("conv_t_s", typingStatus);
}

// Action: conv_msg
///* Handles messages sent to the user
void message(msg.Event event) async {
  logger.i("received");

  // Insert into database
  final message = Message.fromJson(event.data["message"]);
  db.into(db.message).insert(message.entity);

  // Add to chat history
  MessageController controller = Get.find();
  if (controller.selectedConversation.value.id == message.conversation) {
    controller.messages.insert(0, message);
  }
}
