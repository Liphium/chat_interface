import 'package:get/get.dart';

import '../../database/database.dart';

class MessageController extends GetxController {

  final loaded = false.obs;
  final selectedConversation = 0.obs;
  final messages = <Message>[].obs;

  void selectConversation(int value) async {
    selectedConversation.value = value;

    // Load messages
    var loaded = await (db.select(db.message)..where((tbl) => tbl.conversationId.equals(value))).get();
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
  final int sender;
  final DateTime createdAt;
  final int conversation;
  final bool edited;

  Message(this.id, this.content, this.sender, this.createdAt, this.conversation, this.edited);

  Message.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        content = json["content"],
        sender = json["sender"],
        createdAt = json["createdAt"],
        conversation = json["conversation"],
        edited = json["edited"];

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        content = messageData.content,
        sender = messageData.sender!,
        createdAt = messageData.createdAt,
        conversation = messageData.conversationId!,
        edited = messageData.edited;
}