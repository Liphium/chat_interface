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

  final message = chat.Message.fromJson(event.data["message"]);
  final conversation = Get.find<ConversationController>().conversations[message.conversation]!;
  message.content = decryptAES(Encrypted.fromBase64(message.content), conversation.key);

  // Parse content and check signature
  final json = jsonDecode(message.content);
  final status = Get.find<StatusController>();
  var key = message.sender == status.id.value ? asymmetricKeyPair.publicKey : Get.find<FriendController>().friends[message.sender]!.publicKey;

  // Check signature
  message.verified = verifySignature(json["s"], key, hashSha(json["c"]));
  message.content = json["c"];

  // Insert into database
  db.into(db.message).insert(message.entity);

  // Add to chat history
  chat.MessageController controller = Get.find();
  if (controller.selectedConversation.value.id == message.conversation) {
    controller.messages.insert(0, message);
  }
}
