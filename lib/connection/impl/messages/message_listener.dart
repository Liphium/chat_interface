import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/impl/messages/typing_listener.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/chat/message_controller.dart' as chat;
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';

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
void message(Event event) async {
  logger.i("received");

  // Insert into database
  final message = chat.Message.fromJson(event.data["message"]);
  db.into(db.message).insert(message.entity);

  // Add to chat history
  chat.MessageController controller = Get.find();
  if (controller.selectedConversation.value.id == message.conversation) {
    controller.messages.insert(0, message);
  }
}
