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
  final selectedConversation =
      Conversation("0", "", model.ConversationType.directMessage, ConversationToken("", ""), ConversationContainer("hi"), randomSymmetricKey(), 0).obs;
  final messages = <Message>[].obs;

  void unselectConversation({String? id}) {
    if (id != null && selectedConversation.value.id != id) {
      return;
    }
    selectedConversation.value = Conversation("0", "", model.ConversationType.directMessage, ConversationToken("", ""), ConversationContainer("hi"), randomSymmetricKey(), 0);
    messages.clear();
  }

  void selectConversation(Conversation conversation) async {
    //Get.find<WritingController>().init(conversation.id); // TODO: Reimplement typing indicator
    selectedConversation.value = conversation;
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      overwriteRead(conversation);
    }

    // Load messages
    messages.clear();
    var loaded = await (db.select(db.message)
          ..limit(30)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
          ..where((tbl) => tbl.conversationId.equals(conversation.id)))
        .get();

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
    if (json["success"]) {
      conversation.notificationCount.value = 0;
      conversation.readAt.value = DateTime.now().millisecondsSinceEpoch;
    }
  }

  // Delete a message from the client with an id
  void deleteMessageFromClient(String id) async {
    // Get the message from the database on the client
    final data = await (db.message.select()..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (data == null) {
      return;
    }

    // Check if message is in the selected conversation
    if (selectedConversation.value.id == data.conversationId) {
      messages.removeWhere((element) => element.id == id);
    }

    // Delete from the client database
    db.message.deleteWhere((tbl) => tbl.id.equals(id));
  }

  void storeMessage(Message message) async {
    // Update message reading
    Get.find<ConversationController>()
        .updateMessageRead(message.conversation, increment: selectedConversation.value.id != message.conversation, messageSendTime: message.createdAt.millisecondsSinceEpoch);

    // Add message to message history if it's the selected one
    if (selectedConversation.value.id == message.conversation) {
      if (message.sender != selectedConversation.value.token.id) {
        overwriteRead(selectedConversation.value);
      }
      sendLog("MESSAGE RECEIVED ${message.id}");

      // Check if it is a system message and if it should be rendered or not
      if (message.type == MessageType.system) {
        if (SystemMessages.messages[message.content]?.render == true) {
          addMessageToSelected(message);
        }
      } else {
        // Store normal type of message
        if (messages.isNotEmpty && messages[0].id != message.id) {
          addMessageToSelected(message);
        } else if (messages.isEmpty) {
          addMessageToSelected(message);
        }
      }
    }

    // Store message in database
    sendLog(message.type);
    if (message.type == MessageType.system) {
      if (SystemMessages.messages[message.content]?.store == true) {
        sendLog("STORING ${message.content}");
        db.into(db.message).insertOnConflictUpdate(message.entity);
      }
    } else {
      sendLog("WE ARE STORING");
      db.into(db.message).insertOnConflictUpdate(message.entity);
    }

    // Handle system messages
    if (message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message);
    }
  }

  void addMessageToSelected(Message message) {
    int index = 0;
    for (var msg in messages) {
      index++;
      if (msg.createdAt.isAfter(message.createdAt)) {
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
  String answer;
  String signature;
  final String certificate;
  final String sender;
  final String senderAccount;
  final DateTime createdAt;
  final String conversation;
  final bool edited;

  bool renderingAttachments = false;
  final attachmentsRenderer = <AttachmentContainer>[].obs;

  /// Extracts and decrypts the attachments
  void initAttachments() async {
    if (attachmentsRenderer.isNotEmpty || renderingAttachments) {
      return;
    }
    renderingAttachments = true;
    if (attachments.isNotEmpty) {
      sendLog(attachments.length);
      for (var attachment in attachments) {
        if (attachment.isURL) {
          attachmentsRenderer.add(AttachmentContainer.remoteImage(attachment));
          continue;
        }
        final json = jsonDecode(attachment);
        final type = await AttachmentController.checkLocations(json["id"], StorageType.temporary);
        final decoded = AttachmentContainer.fromJson(type, json);
        var container = await Get.find<AttachmentController>().findLocalFile(decoded);
        sendLog("FOUND: ${container?.filePath}");
        if (container == null) {
          final extension = decoded.id.split(".").last;
          if (FileSettings.imageTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadImages]!.getValue();
            if (download) {
              Get.find<AttachmentController>().downloadAttachment(decoded);
            }
          } else if (FileSettings.videoTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadVideos]!.getValue();
            if (download) {
              Get.find<AttachmentController>().downloadAttachment(decoded);
            }
          } else if (FileSettings.audioTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadAudio]!.getValue();
            if (download) {
              Get.find<AttachmentController>().downloadAttachment(decoded);
            }
          }
          container = decoded;
        }
        attachmentsRenderer.add(container);
      }
      renderingAttachments = false;
    }
  }

  Message(
    this.id,
    this.type,
    this.content,
    this.answer,
    this.attachments,
    this.signature,
    this.certificate,
    this.sender,
    this.senderAccount,
    this.createdAt,
    this.conversation,
    this.edited,
    bool verified,
  ) {
    this.verified.value = verified;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    // Convert to message
    final account = Get.find<ConversationController>().conversations[json["conversation"]]!.members[json["sender"]]?.account ?? "removed";
    var message = Message(json["id"], MessageType.text, json["data"], "", [], "", json["certificate"], json["sender"], account,
        DateTime.fromMillisecondsSinceEpoch(json["creation"]), json["conversation"], json["edited"], false);

    // Decrypt content
    final conversation = Get.find<ConversationController>().conversations[json["conversation"]]!;
    if (message.sender == MessageController.systemSender) {
      message.verified.value = true;
      message.type = MessageType.system;
      message.loadContent();
      sendLog("SYSTEM MESSAGE");
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
    if (type != MessageType.system) {
      type = MessageType.values[contentJson["t"] ?? 0];
      if (type == MessageType.text) {
        content = utf8.decode(base64Decode(contentJson["c"]));
      } else {
        content = contentJson["c"];
      }
      signature = contentJson["s"];
    } else {
      content = contentJson["c"];
    }
    attachments = List<String>.from(contentJson["a"] ?? [""]);
    answer = contentJson["r"] ?? "";
  }

  /// Verifies the signature of the message
  void verifySignature() async {
    final conversation = Get.find<ConversationController>().conversations[this.conversation]!;
    sendLog("${conversation.members} | ${this.sender}");
    final sender = await Get.find<UnknownController>().loadUnknownProfile(conversation.members[this.sender]!.account);
    if (sender == null) {
      sendLog("NO SENDER FOUND");
      verified.value = false;
      return;
    }
    String hash;
    if (type != MessageType.text) {
      final contentJson = jsonEncode(<String, dynamic>{
        "c": content,
        "t": type.index,
        "a": attachments,
        "r": answer,
      });
      hash = hashSha(contentJson + createdAt.millisecondsSinceEpoch.toStringAsFixed(0) + conversation.id);
    } else {
      final contentJson = jsonEncode(<String, dynamic>{
        "c": base64Encode(utf8.encode(content)),
        "t": type.index,
        "a": attachments,
        "r": answer,
      });
      hash = hashSha(contentJson + createdAt.millisecondsSinceEpoch.toStringAsFixed(0) + conversation.id);
    }
    sendLog("MESSAGE HASH: $hash ${content + conversation.id}");
    verified.value = checkSignature(signature, sender.signatureKey, hash);
    db.message.insertOnConflictUpdate(entity);
    if (!verified.value) {
      sendLog("invalid signature");
    } else {
      sendLog("valid signature");
    }
  }

  Message.fromMessageData(MessageData messageData)
      : id = messageData.id,
        type = MessageType.values[messageData.type],
        content = messageData.content,
        answer = messageData.answer,
        attachments = List<String>.from(jsonDecode(messageData.attachments)),
        certificate = messageData.certificate,
        sender = messageData.sender,
        senderAccount = messageData.senderAccount,
        createdAt = DateTime.fromMillisecondsSinceEpoch(messageData.createdAt.toInt()),
        conversation = messageData.conversationId,
        signature = messageData.signature,
        edited = messageData.edited {
    verified.value = messageData.verified;
  }

  MessageData get entity => MessageData(
        id: id,
        type: type.index,
        content: content,
        answer: answer,
        signature: signature,
        attachments: jsonEncode(attachments),
        certificate: certificate,
        sender: sender,
        senderAccount: senderAccount,
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
      if (attachments[i].startsWith("a:")) {
        attachments[i] = jsonDecode(decryptSymmetric(attachments[i].substring(2), conv.key))["id"];
      }
    }
    if (SystemMessages.messages[content]?.store == true) {
      db.message.insertOnConflictUpdate(entity);
    }
  }

  /// Delete message on the server (and on the client)
  ///
  /// Returns null if successful, otherwise an error message
  Future<String?> delete() async {
    // Check if the message is sent by the user
    final token = Get.find<ConversationController>().conversations[conversation]!.token;
    if (sender != token.id) {
      return "no.permission";
    }

    // Send a request to the server
    final json = await postNodeJSON("/conversations/message/delete", {
      "certificate": certificate,
      "id": token.id,
      "token": token.token,
    });
    sendLog(json);

    if (!json["success"]) {
      if (json["error"] == "server.error") {
        return "message.delete_error";
      }
      return json["error"];
    }

    return null;
  }
}

enum MessageType {
  text,
  system,
  call;
}
