import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/conversation_page.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

enum OpenTabType {
  conversation,
  space,
  townsquare;
}

class MessageController extends GetxController {
  // Constants
  Message? hoveredMessage;
  static String systemSender = "6969";

  final loaded = false.obs;
  final currentOpenType = OpenTabType.conversation.obs;
  final currentConversation = Rx<Conversation?>(null);
  final messages = <Message>[].obs;

  void unselectConversation({String? id}) {
    if (id != null && currentConversation.value?.id == id) {
      return;
    }
    currentConversation.value = null;
    messages.clear();
  }

  void selectConversation(Conversation conversation) async {
    currentOpenType.value = OpenTabType.conversation;
    Get.find<TownsquareController>().close();
    loaded.value = false;
    if (isMobileMode()) {
      Get.to(ConversationPage(conversation: conversation));
    }
    currentConversation.value = conversation;
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      overwriteRead(conversation);
    }

    // Load messages
    messages.clear();
    var loadedMessages = await (db.select(db.message)
          ..limit(messageLimit)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
          ..where((tbl) => tbl.conversationId.equals(conversation.id))
          ..where((tbl) => tbl.system.equals(false)))
        .get();

    for (var message in loadedMessages) {
      final msg = Message.fromMessageData(message);
      await msg.initAttachments();
      messages.add(msg);
    }
    loaded.value = true;
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

  /// Delete all system messages of the same kind before the message send time
  void deleteOldSystemMessagesOfKind(String id, String kind, DateTime after) {
    db.message.delete()
      ..where((tbl) => tbl.content.equals(kind))
      ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(after.millisecondsSinceEpoch)))
      ..where((tbl) => tbl.id.isNotValue(id))
      ..go();
  }

  // Delete a message from the client with an id
  void deleteMessageFromClient(String conversation, String id) async {
    // Get the message from the database on the client
    final data = await (db.message.select()
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.conversationId.equals(conversation)))
        .getSingleOrNull();
    if (data == null) {
      return;
    }

    // Check if message is in the selected conversation
    if (currentConversation.value?.id == data.conversationId) {
      messages.removeWhere((element) => element.id == id);
    }

    // Delete from the client database
    db.message.deleteWhere((tbl) => tbl.id.equals(id));
  }

  void storeMessage(Message message) async {
    // Update message reading
    Get.find<ConversationController>().updateMessageRead(
      message.conversation,
      increment: currentConversation.value?.id != message.conversation,
      messageSendTime: message.createdAt.millisecondsSinceEpoch,
    );

    // Add message to message history if it's the selected one
    if (currentConversation.value?.id == message.conversation) {
      if (message.sender != currentConversation.value?.token.id) {
        overwriteRead(currentConversation.value!);
      }

      // Check if message with this id already exists
      final msg = await (db.message.select()
            ..where((tbl) => tbl.id.equals(message.id))
            ..where((tbl) => tbl.conversationId.equals(message.conversation)))
          .getSingleOrNull();
      if (msg != null) {
        return;
      }

      // Check if it is a system message and if it should be rendered or not
      if (message.type == MessageType.system) {
        if (SystemMessages.messages[message.content]?.render == true) {
          addMessageToBottom(message);
        }
      } else {
        // Store normal type of message
        if (messages.isNotEmpty && messages[0].id != message.id) {
          addMessageToBottom(message);
        } else if (messages.isEmpty) {
          addMessageToBottom(message);
        }
      }
    }

    // Store message in database
    sendLog(message.type);
    if (message.type == MessageType.system) {
      if (SystemMessages.messages[message.content]?.store == true) {
        db.into(db.message).insertOnConflictUpdate(message.entity(!SystemMessages.messages[message.content]!.render));
      }
    } else {
      db.into(db.message).insertOnConflictUpdate(message.entity(false));
    }

    // Handle system messages
    if (message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message);
    }
  }

  //* Scroll
  static const messageLimit = 10;
  static const newLoadOffset = 200;
  late material.ScrollController controller;

  void addMessageToBottom(Message message, {bool animation = true}) async {
    // Check if there are more messages after the current messages (just in case)
    if (messages.isNotEmpty) {
      final availableMessage = await (db.select(db.message)
            ..limit(1)
            ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
            ..where((tbl) => tbl.conversationId.equals(currentConversation.value!.id))
            ..where((tbl) => tbl.system.equals(false))
            ..where((tbl) => tbl.id.isNotValue(message.id))
            ..where((tbl) => tbl.createdAt.isBiggerThanValue(BigInt.from(messages.first.createdAt.millisecondsSinceEpoch))))
          .getSingleOrNull();

      // If there is a message before this one at the bottom, don't render
      if (availableMessage != null) {
        sendLog("OLDER MESSAGE, ignoring");
        return;
      }
    }

    // Initialize all message data
    await message.initAttachments();

    // Only load the message, if scrolled near enough to the bottom
    if (controller.position.pixels <= newLoadOffset) {
      if (controller.position.pixels == 0) {
        message.playAnimation = true;
        messages.insert(0, message);
        return;
      }

      message.heightCallback = true;
      messages.insert(0, message);
      return;
    }
  }

  void messageHeightCallback(Message message, double height) {
    message.canScroll.value = true;
    message.currentHeight = height;
    controller.jumpTo(controller.position.pixels + height);
  }

  void messageHeightChange(Message message, double extraHeight) {
    if (message.heightKey != null) {
      controller.jumpTo(controller.position.pixels + extraHeight);
    }
  }

  void newScrollController(material.ScrollController newController) {
    controller = newController;
    controller.addListener(() => checkCurrentScrollHeight());
  }

  // Run on every scroll to check if new messages should be loaded
  void checkCurrentScrollHeight() {
    if (controller.position.pixels > controller.position.maxScrollExtent - newLoadOffset) {
      sendLog("load top");
      loadNewMessagesTop();
    } else if (controller.position.pixels <= newLoadOffset) {
      sendLog("load bottom");
      loadNewMessagesBottom();
    }
  }

  // Loading state for new messages (at top or bottom)
  bool loading = false;

  /// Load "messageLimit" new messages at the top
  void loadNewMessagesTop() async {
    if (loading || messages.isEmpty) {
      return;
    }
    loading = true;
    final finalMessage = messages.last;

    // Get the the "messageLimit" newest messages, that aren't system messages (like delete or react)
    final loadedMessages = await (db.select(db.message)
          ..limit(messageLimit)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
          ..where((tbl) => tbl.conversationId.equals(currentConversation.value!.id))
          ..where((tbl) => tbl.system.equals(false))
          ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(finalMessage.createdAt.millisecondsSinceEpoch))))
        .get();

    // Add them all to a list (adding them one by one would cause one giant state update since we use async code here)
    final newMessages = <Message>[];
    for (var msg in loadedMessages) {
      final message = Message.fromMessageData(msg);
      await message.initAttachments();
      newMessages.add(message);
    }
    loading = false;

    if (newMessages.isEmpty) {
      return;
    }

    messages.addAll(newMessages);
    loading = false;
  }

  /// Load "messageLimit" new messages at the bottom
  void loadNewMessagesBottom() async {
    if (loading || messages.isEmpty) {
      sendLog("loading or sth");
      return;
    }
    loading = true; // We'll use the same loading as above to make sure this doesn't break anything
    final firstMessage = messages.first;

    // Get the the "messageLimit" newest messages, that aren't system messages (like delete or react)
    final loadedMessages = await (db.select(db.message)
          ..limit(messageLimit)
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
          ..where((tbl) => tbl.conversationId.equals(currentConversation.value!.id))
          ..where((tbl) => tbl.system.equals(false))
          ..where((tbl) => tbl.createdAt.isBiggerThanValue(BigInt.from(firstMessage.createdAt.millisecondsSinceEpoch))))
        .get();

    sendLog(loadedMessages.length);

    // Add them all to a list (adding them one by one would cause one giant state update since we use async code here)
    final newMessages = <Message>[];
    for (var msg in loadedMessages) {
      final message = Message.fromMessageData(msg);
      await message.initAttachments();
      message.heightCallback = true; // To prevent the viewport from scrolling up
      newMessages.add(message);
    }
    loading = false;

    if (newMessages.isEmpty) {
      return;
    }

    // Add them all to the bottom
    messages.insertAll(0, newMessages);
  }
}

class Message {
  final String id;
  MessageType type;
  String content;
  List<String> attachments;
  final verified = true.obs;
  String answer;
  final String certificate;
  final String sender;
  final String senderAccount;
  final DateTime createdAt;
  final String conversation;
  final bool edited;

  final canScroll = false.obs;
  double? currentHeight;
  GlobalKey? heightKey;
  bool heightReported = false;
  bool heightCallback = false;
  bool renderingAttachments = false;
  final attachmentsRenderer = <AttachmentContainer>[];
  Message? answerMessage;

  /// Extracts and decrypts the attachments
  Future<bool> initAttachments() async {
    //* Load answer
    if (answer != "") {
      final message = await (db.message.select()
            ..where((tbl) => tbl.id.equals(answer))
            ..where((tbl) => tbl.conversationId.equals(conversation)))
          .getSingleOrNull();
      if (message != null) {
        answerMessage = Message.fromMessageData(message);
      }
    } else {
      answerMessage = null;
    }

    //* Load attachments
    if (attachmentsRenderer.isNotEmpty || renderingAttachments) {
      return true;
    }
    renderingAttachments = true;
    if (attachments.isNotEmpty) {
      for (var attachment in attachments) {
        if (attachment.isURL) {
          final container = AttachmentContainer.remoteImage(attachment);
          await container.init();
          attachmentsRenderer.add(container);
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

    return true;
  }

  //* Animation when a new message enters the chat
  bool playAnimation = false;
  material.AnimationController? controller;
  void initAnimation(material.TickerProvider provider) {
    if (controller != null) {
      return;
    }

    controller = material.AnimationController(vsync: provider, duration: 250.ms);
    Timer(250.ms, () {
      controller!.forward(from: 0);
    });
  }

  Message(
    this.id,
    this.type,
    this.content,
    this.answer,
    this.attachments,
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
    var message = Message(json["id"], MessageType.text, json["data"], "", [], json["certificate"], json["sender"], account,
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
    final info = SymmetricSequencedInfo.extract(message.content, conversation.key);
    message.content = info.text;
    message.loadContent();
    message.verifySignature(info);

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
    } else {
      content = contentJson["c"];
    }
    attachments = List<String>.from(contentJson["a"] ?? [""]);
    answer = contentJson["r"] ?? "";
  }

  /// Verifies the signature of the message
  void verifySignature(SymmetricSequencedInfo info) async {
    final conversation = Get.find<ConversationController>().conversations[this.conversation]!;
    sendLog("${conversation.members} | ${this.sender}");
    final sender = await Get.find<UnknownController>().loadUnknownProfile(conversation.members[this.sender]!.account);
    if (sender == null) {
      sendLog("NO SENDER FOUND");
      verified.value = false;
      return;
    }
    verified.value = info.verifySignature(sender.signatureKey);
    db.message.insertOnConflictUpdate(entity(false));
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
        edited = messageData.edited {
    verified.value = messageData.verified;
  }

  MessageData entity(bool system) {
    return MessageData(
      id: id,
      type: type.index,
      content: content,
      answer: answer,
      attachments: jsonEncode(attachments),
      certificate: certificate,
      sender: sender,
      senderAccount: senderAccount,
      createdAt: BigInt.from(createdAt.millisecondsSinceEpoch),
      conversationId: conversation,
      edited: edited,
      verified: verified.value,
      system: system,
    );
  }

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
      db.message.insertOnConflictUpdate(entity(!SystemMessages.messages[content]!.render));
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
  call,
  liveshare;
}
