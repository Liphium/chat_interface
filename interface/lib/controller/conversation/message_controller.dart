import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';


class MessageController extends GetxController {

  final loaded = false.obs;
  final selectedConversation = Conversation("0", ConversationToken("", ""), ConversationContainer("hi"), randomSymmetricKey(), 0).obs;
  final messages = <Message>[].obs;

  void unselectConversation() {
    selectedConversation.value = Conversation("0", ConversationToken("", ""), ConversationContainer("hi"), randomSymmetricKey(), 0);
    messages.clear();
  }

  void selectConversation(Conversation conversation) async {
    //Get.find<WritingController>().init(conversation.id); // TODO: Reimplement typing indicator
    selectedConversation.value = conversation;
    if(conversation.notificationCount.value != 0) {
      
      // Send new read state to the server
      overwriteRead(conversation);
    }

    // Load messages
    messages.clear();
    var loaded = await (db.select(db.message)..limit(30)..orderBy([(u) => OrderingTerm.desc(u.createdAt)])..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

    for (var message in loaded) {
      messages.add(Message.fromMessageData(message));
    }
  }

  // Push read state to the server
  void overwriteRead(Conversation conversation) async {

    // Send new read state to the server
    final json = await postNodeJSON("/conversations/read", {
      "id": conversation.token.id,
      "token": conversation.token.token,
    });
    if(json["success"]) {
      conversation.notificationCount.value = 0;
      conversation.readAt.value = DateTime.now().millisecondsSinceEpoch;
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

  void storeMessage(Message message) {
    Get.find<ConversationController>().updateMessageRead(
      message.conversation, 
      increment: selectedConversation.value.id != message.conversation, 
      messageSendTime: message.createdAt.millisecondsSinceEpoch
    );
    if(selectedConversation.value.id == message.conversation) {
      if(message.sender != selectedConversation.value.token.id) {
        overwriteRead(selectedConversation.value);
      }
      if(messages.isNotEmpty && messages[0].id != message.id) {
        messages.insert(0, message);        
      } else if(messages.isEmpty) {
        messages.insert(0, message);
      }
    }
    db.into(db.message).insertOnConflictUpdate(message.entity);
  }

}

class Message {
    
  final String id;
  MessageType type; // text, audio, call, stream
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
      MessageType.text,
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
    final conversation = Get.find<ConversationController>().conversations[json["conversation"]]!;
    message.content = decryptSymmetric(message.content, conversation.key);
    // TODO: Add a signature (check it ig)

    // Parse content and check signature
    final contentJson = jsonDecode(message.content);

    // Check signature
    message.verified = true;
    message.type = MessageType.fromString(contentJson["t"] ?? "text");
    if(message.type == MessageType.text) {
      message.content = utf8.decode(base64Decode(contentJson["c"]));
    }
    message.attachments = contentJson["a"] ?? "";

    return message;
  }

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        type = MessageType.fromString(messageData.type),
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
        type: type.name,
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

enum MessageType {
  text("text"),
  call("call");

  final String name;

  const MessageType(this.name);

  static MessageType fromString(String name) {
    switch (name) {
      case "text":
        return MessageType.text;
      case "call":
        return MessageType.call;
      default:
        return MessageType.text;
    }
  }

}