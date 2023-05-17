import 'dart:convert';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/account/writing_controller.dart';
import 'package:chat_interface/controller/chat/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';


class MessageController extends GetxController {

  final loaded = false.obs;
  final selectedConversation = Conversation("0", "data", "").obs;
  final messages = <Message>[].obs;

  void selectConversation(Conversation conversation) async {

    Get.find<WritingController>().init(conversation.id);
    selectedConversation.value = conversation;

    // Load messages
    messages.clear();
    var loaded = await (db.select(db.message)..limit(60)..orderBy([(u) => OrderingTerm.desc(u.createdAt)])..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

    for (var message in loaded) {
      messages.add(Message.fromMessageData(message));
    }
  }

  void newMessages(dynamic messages) async {
    loaded.value = true;
    if(messages == null) {
      return;
    }
    
    for (var msg in messages) {

      final message = Message.fromJson(msg);
      await db.into(db.message).insertOnConflictUpdate(message.entity);
    }
  }

}

class Message {
    
  final String id;
  String type; // text, audio, call, stream
  String content;
  String attachments;
  bool verified;
  final String certificate;
  final String sender;
  final DateTime createdAt;
  final String conversation;
  final bool edited;

  Message(this.id, this.type, this.content, this.attachments, this.certificate, this.sender, this.createdAt, this.conversation, this.edited, this.verified);

  factory Message.fromJson(Map<String, dynamic> json) {

    // Convert to message
    final message = Message(
      json["id"],
      "",
      json["data"],
      "",
      json["certificate"],
      json["sender"],
      DateTime.fromMillisecondsSinceEpoch(json["creation"]),
      json["conversation"],
      json["edited"],
      false
    );

    // Decrypt content
    final conversation = Get.find<ConversationController>().conversations[message.conversation]!;
    message.content = decryptAES(Encrypted.fromBase64(message.content), conversation.key);

    // Parse content and check signature
    final contentJson = jsonDecode(message.content);
    final status = Get.find<StatusController>();
    var key = message.sender == status.id.value ? asymmetricKeyPair.publicKey : Get.find<FriendController>().friends[message.sender]!.publicKey;

    // Check signature
    message.verified = verifySignature(contentJson["s"], key, hashSha(contentJson["c"]));
    message.content = contentJson["c"];
    message.type = contentJson["t"] ?? "text";
    message.attachments = contentJson["a"] ?? "";

    return message;
  }

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        type = messageData.type,
        content = messageData.content,
        attachments = messageData.attachments,
        certificate = messageData.certificate,
        sender = messageData.sender!,
        createdAt = messageData.createdAt,
        conversation = messageData.conversationId!,
        edited = messageData.edited,
        verified = messageData.verified;

  MessageData get entity => MessageData(
        id: id,
        type: type,
        content: content,
        attachments: attachments,
        certificate: certificate,
        sender: sender,
        createdAt: createdAt,
        conversationId: conversation,
        edited: edited,
        verified: verified
      );

  Map<String, dynamic> toJson() {
  
    return <String, dynamic>{};
  }
}
      