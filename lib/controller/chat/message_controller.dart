import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

import '../../database/database.dart';

class MessageController extends GetxController {

  final loaded = false.obs;
  final selectedConversation = Conversation(0, "data").obs;
  final messages = <Message>[].obs;

  void selectConversation(Conversation conversation) async {
    selectedConversation.value = conversation;

    // Load messages
    messages.clear();
    var loaded = await (db.select(db.message)..limit(60)..orderBy([(u) => OrderingTerm.desc(u.createdAt)])..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

    for (var message in loaded) {
      messages.add(Message.fromMessageData(message));
    }
  }

  void newMessages(dynamic messages) {
    loaded.value = true;
    if(messages == null) {
      return;
    }

    for (var message in messages) {
      this.messages.add(Message.fromJson(message));
    }
  }

}

class Message {
    
  final String id;
  final String content;
  final String certificate;
  final int sender;
  final DateTime createdAt;
  final int conversation;
  final bool edited;

  Message(this.id, this.content, this.certificate, this.sender, this.createdAt, this.conversation, this.edited);

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        json["id"],
        json["data"],
        json["certificate"],
        json["sender"],
        DateTime.fromMillisecondsSinceEpoch(json["creation"]),
        json["conversation"],
        json["edited"],
      );

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        content = messageData.content,
        certificate = messageData.certificate,
        sender = messageData.sender!,
        createdAt = messageData.createdAt,
        conversation = messageData.conversationId!,
        edited = messageData.edited;

  MessageData get entity => MessageData(
        id: id,
        content: content,
        certificate: certificate,
        sender: sender,
        createdAt: createdAt,
        conversationId: conversation,
        edited: edited,
      );
}