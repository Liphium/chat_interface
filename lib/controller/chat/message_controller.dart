import 'dart:convert';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/controller/chat/writing_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';

import '../../database/database.dart';

class MessageController extends GetxController {

  final loaded = false.obs;
  final selectedConversation = Conversation(0, "data", "").obs;
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

    final controller = Get.find<FriendController>();
    final status = Get.find<StatusController>();
    for (var msg in messages) {

      final message = Message.fromJson(msg);
      final conversation = Get.find<ConversationController>().conversations[message.conversation]!;
      message.content = decryptAES(Encrypted.fromBase64(message.content), conversation.key);

      // Parse content and check signature
      final json = jsonDecode(message.content);
      var key = message.sender == status.id.value ? asymmetricKeyPair.publicKey : controller.friends[message.sender]!.publicKey;

      // Check signature
      message.verified = verifySignature(json["s"], key, hashSha(json["c"]));
      message.content = json["c"];

      await db.into(db.message).insertOnConflictUpdate(message.entity);
    }
  }

}

class Message {
    
  final String id;
  String content;
  bool verified;
  final String certificate;
  final int sender;
  final DateTime createdAt;
  final int conversation;
  final bool edited;

  Message(this.id, this.content, this.certificate, this.sender, this.createdAt, this.conversation, this.edited, this.verified);

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        json["id"],
        json["data"],
        json["certificate"],
        json["sender"],
        DateTime.fromMillisecondsSinceEpoch(json["creation"]),
        json["conversation"],
        json["edited"],
        false,
      );

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        content = messageData.content,
        certificate = messageData.certificate,
        sender = messageData.sender!,
        createdAt = messageData.createdAt,
        conversation = messageData.conversationId!,
        edited = messageData.edited,
        verified = messageData.verified;

  MessageData get entity => MessageData(
        id: id,
        content: content,
        certificate: certificate,
        sender: sender,
        createdAt: createdAt,
        conversationId: conversation,
        edited: edited,
        verified: verified
      );
}