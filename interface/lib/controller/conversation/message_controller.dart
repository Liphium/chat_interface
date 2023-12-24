import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/database/conversation/conversation.dart' as model;
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
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

  void storeMessage(Message message) async {

    // Handle attachments
    if(message.attachments.isNotEmpty && message.type != MessageType.system) {
      for(var attachment in message.attachments) {
        final container = AttachmentContainer.fromJson(jsonDecode(attachment));
        final extension = container.url.split(".").last;

        if(FileSettings.imageTypes.contains(extension)) {
          final download = Get.find<SettingController>().settings[FileSettings.autoDownloadImages]!.getValue();
          if(download) {
            await Get.find<AttachmentController>().downloadAttachment(container);
          }
        } else if(FileSettings.videoTypes.contains(extension)) {
          final download = Get.find<SettingController>().settings[FileSettings.autoDownloadVideos]!.getValue();
          if(download) {
            await Get.find<AttachmentController>().downloadAttachment(container);
          }
        } else if(FileSettings.audioTypes.contains(extension)) {
          final download = Get.find<SettingController>().settings[FileSettings.autoDownloadAudio]!.getValue();
          if(download) {
            await Get.find<AttachmentController>().downloadAttachment(container);
          }
        }
      }
    }

    // Update message reading
    Get.find<ConversationController>().updateMessageRead(
      message.conversation, 
      increment: selectedConversation.value.id != message.conversation, 
      messageSendTime: message.createdAt.millisecondsSinceEpoch
    );

    // Add message to message history if it's the selected one
    if(selectedConversation.value.id == message.conversation) {
      if(message.sender != selectedConversation.value.token.id) {
        overwriteRead(selectedConversation.value);
      }
      sendLog("MESSAGE RECEIVED ${message.id}");
      if(messages.isNotEmpty && messages[0].id != message.id) {
        addMessageToSelected(message);
      } else if(messages.isEmpty) {
        addMessageToSelected(message);
      }
    }

    // Store message in database
    db.into(db.message).insertOnConflictUpdate(message.entity);

    // Handle system messages
    if(message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message);
    }
  }

  void addMessageToSelected(Message message) {
    int index = 0;
    for(var msg in messages) {
      index++;
      if(msg.createdAt.isAfter(message.createdAt)) {
        continue;
      }
      index -= 1;
      break;
    }
    messages.insert(index, message);
  }

}

class Message {
    
  final String id;
  MessageType type;
  String content;
  List<String> attachments;
  final verified = true.obs;
  String signature;
  final String certificate;
  final String sender;
  final DateTime createdAt;
  final String conversation;
  final bool edited;

  final attachmentsRenderer = <AttachmentContainer>[].obs;

  /// Extracts and decrypts the attachments
  void initAttachments() async {
    if(attachmentsRenderer.isNotEmpty) {
      return;
    }
    if(attachments.isNotEmpty) {
      for (var attachment in attachments) {
        final decoded = AttachmentContainer.fromJson(jsonDecode(attachment));
        final container = await Get.find<AttachmentController>().findLocalFile(decoded);
        sendLog("FOUND: ${container?.filePath}");
        if(container == null) {
          attachmentsRenderer.add(decoded);
        } else {
          attachmentsRenderer.add(container);
        }
      }
    }
  }

  Message(this.id, this.type, this.content, this.attachments, this.signature, this.certificate, this.sender, this.createdAt, this.conversation, this.edited, bool verified) {
    this.verified.value = verified;
  }

  factory Message.fromJson(Map<String, dynamic> json) {

    // Convert to message
    var message = Message(
      json["id"],
      MessageType.text,
      json["data"],
      [""],
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
    if(message.sender == MessageController.systemSender) {
      message.verified.value = true;
      message.type = MessageType.system;
      message.loadContent();
      return message;
    }

    // Check signature
    message.content = decryptSymmetric(message.content, conversation.key);
    message.loadContent();
    message.verifySignature();

    return message;
  }

  /// Loads the content from the message (signature, type, content)
  void loadContent({Map<String, dynamic>? json}) {
    final contentJson = json ?? jsonDecode(content);
    if(type != MessageType.system) {
      type = MessageType.values[contentJson["t"] ?? 0];
      if(type == MessageType.text) {
        content = utf8.decode(base64Decode(contentJson["c"]));
      } else {
        content = contentJson["c"];
      }
      signature = contentJson["s"];
    } else {
      content = contentJson["c"];
    }
    attachments = List<String>.from(contentJson["a"] ?? [""]);
  }

  /// Verifies the signature of the message
  void verifySignature() async {
    final conversation = Get.find<ConversationController>().conversations[this.conversation]!;
    sendLog("${conversation.members} | ${this.sender}");
    final sender = await Get.find<UnknownController>().loadUnknownProfile(conversation.members[this.sender]!.account);
    if(sender == null) {
      sendLog("NO SENDER FOUND");
      verified.value = false;
      return;
    }
    String hash;
    if(type != MessageType.text) {
      hash = hashSha(content + createdAt.millisecondsSinceEpoch.toStringAsFixed(0) + conversation.id);
    } else {
      hash = hashSha(base64Encode(utf8.encode(content)) + createdAt.millisecondsSinceEpoch.toStringAsFixed(0) + conversation.id);
    }
    sendLog("MESSAGE HASH: $hash ${content + conversation.id}");
    verified.value = checkSignature(signature, sender.signatureKey, hash);
    db.message.insertOnConflictUpdate(entity);
    if(!verified.value) {
      sendLog("invalid signature");
    } else {
      sendLog("valid signature");
    }
  }

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        type = MessageType.values[messageData.type],
        content = messageData.content,
        attachments = List<String>.from(jsonDecode(messageData.attachments)),
        certificate = messageData.certificate,
        sender = messageData.sender!,
        createdAt = DateTime.fromMillisecondsSinceEpoch(messageData.createdAt.toInt()),
        conversation = messageData.conversationId!,
        signature = messageData.signature,
        edited = messageData.edited {
    verified.value = messageData.verified;
  }

  MessageData get entity => MessageData(
        id: id,
        type: type.index,
        content: content,
        signature: signature,
        attachments: jsonEncode(attachments),
        certificate: certificate,
        sender: sender,
        createdAt: BigInt.from(createdAt.millisecondsSinceEpoch),
        conversationId: conversation,
        edited: edited,
        verified: verified.value,
      );

  Map<String, dynamic> toJson() {
  
    return <String, dynamic>{};
  }

  /// Decrypts the account ids of a system message
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