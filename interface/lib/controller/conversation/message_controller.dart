import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/database/conversation/conversation.dart' as model;
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';


class MessageController extends GetxController {

  // Constants
  static String systemSender = "6969"; 

  final loaded = false.obs;
  final selectedConversation = Conversation("0", "", model.ConversationType.directMessage, ConversationToken("", ""), ConversationContainer("hi"), randomSymmetricKey(), 0).obs;
  final messages = <Message>[].obs;

  void unselectConversation({String? id}) {
    if(id != null && selectedConversation.value.id != id) {
      return;
    }
    selectedConversation.value = Conversation("0", "", model.ConversationType.directMessage, ConversationToken("", ""), ConversationContainer("hi"), randomSymmetricKey(), 0);
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

    // Handle system messages
    if(message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message);
    }

    // Handle attachments
    if(message.attachments.isNotEmpty && message.type != MessageType.system) {
      for(var attachment in message.attachments) {
        final container = AttachmentContainer.fromJson(jsonDecode(attachment));
        final extension = container.url.split(".").last;

        if(FileSettings.imageTypes.contains(extension)) {
          final download = Get.find<SettingController>().settings[FileSettings.autoDownloadImages]!.getValue();
          if(download) {
            Get.find<AttachmentController>().downloadAttachment(container);
          }
        } else if(FileSettings.videoTypes.contains(extension)) {
          final download = Get.find<SettingController>().settings[FileSettings.autoDownloadVideos]!.getValue();
          if(download) {
            Get.find<AttachmentController>().downloadAttachment(container);
          }
        } else if(FileSettings.audioTypes.contains(extension)) {
          final download = Get.find<SettingController>().settings[FileSettings.autoDownloadAudio]!.getValue();
          if(download) {
            Get.find<AttachmentController>().downloadAttachment(container);
          }
        }
      }
    }
  }

}

class Message {
    
  final String id;
  MessageType type;
  String content;
  List<String> attachments;
  bool verified;
  final String certificate;
  final String sender;
  final DateTime createdAt;
  final String conversation;
  final bool edited;

  Message(this.id, this.type, this.content, this.attachments, this.certificate, this.sender, this.createdAt, this.conversation, this.edited, this.verified);

  factory Message.fromJson(Map<String, dynamic> json) {

    // Convert to message
    var message = Message(
      json["id"],
      MessageType.text,
      json["data"],
      [""],
      json["certificate"],
      json["sender"],
      DateTime.fromMillisecondsSinceEpoch(json["creation"]),
      json["conversation"],
      json["edited"],
      false
    );

    // Decrypt content
    final conversation = Get.find<ConversationController>().conversations[json["conversation"]]!;
    if(message.sender == MessageController.systemSender) {
      message.verified = true;
      message.type = MessageType.system;
      message.loadContent();
      return message;
    }

    // TODO: Add a signature (and verify it)
    // Check signature
    message.verified = true;
    message.content = decryptSymmetric(message.content, conversation.key);
    message.loadContent();

    return message;
  }

  void loadContent() {
    final contentJson = jsonDecode(content);
    if(type != MessageType.system) {
      type = MessageType.values[contentJson["t"] ?? 0];
      if(type == MessageType.text) {
        content = utf8.decode(base64Decode(contentJson["c"]));
      }
    } else {
      content = contentJson["c"];
    }
    attachments = List<String>.from(contentJson["a"] ?? [""]);
  }

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        type = MessageType.values[messageData.type],
        content = messageData.content,
        attachments = List<String>.from(jsonDecode(messageData.attachments)),
        certificate = messageData.certificate,
        sender = messageData.sender!,
        createdAt = messageData.createdAt,
        conversation = messageData.conversationId!,
        edited = messageData.edited,
        verified = messageData.verified;

  MessageData get entity => MessageData(
        id: id,
        type: type.index,
        content: content,
        attachments: jsonEncode(attachments),
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

  void decryptSystemMessageAttachments() {
    final conv = Get.find<ConversationController>().conversations[conversation]!;
    for (var i = 0; i < attachments.length; i++) {
      if(attachments[i].startsWith("a:")) {
        attachments[i] = jsonDecode(decryptSymmetric(attachments[i].substring(2), conv.key))["id"];
      }
    }
    db.message.insertOnConflictUpdate(entity);
  }
}

enum MessageType {
  text,
  system,
  call;
}