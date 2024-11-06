import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sodium_libs/sodium_libs.dart';

abstract class MessageProvider {
  final messages = <Message>[].obs;
  final waitingMessages = <String>[]; // To prevent messages from being sent twice due to a race condition

  //* Scroll
  static const newLoadOffset = 200;
  bool topReached = false;
  AutoScrollController? controller;

  void addMessageToBottom(Message message, {bool animation = true}) async {
    // Check if there are any messages with similar ids to prevent adding the same message again
    if (waitingMessages.any((msg) => msg == message.id)) {
      return;
    }
    waitingMessages.add(message.id);

    // Initialize all message data
    await message.initAttachments(this);
    waitingMessages.remove(message.id); // Remove after cause then it is added

    // Only load the message, if scrolled near enough to the bottom
    if (controller!.position.pixels <= newLoadOffset) {
      if (controller!.position.pixels == 0) {
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
    controller!.jumpTo(controller!.position.pixels + height);
  }

  void messageHeightChange(Message message, double extraHeight) {
    if (message.heightKey != null) {
      controller!.jumpTo(controller!.position.pixels + extraHeight);
    }
  }

  void newScrollController(AutoScrollController newController) {
    if (controller != null) {
      controller!.removeListener(checkCurrentScrollHeight);
    }
    controller = newController;
    controller!.addListener(checkCurrentScrollHeight);
  }

  /// Runs on every scroll to check if new messages should be loaded
  void checkCurrentScrollHeight() async {
    // Get.height is in there because there is a little bit of buffer above
    if (controller!.position.pixels > controller!.position.maxScrollExtent - Get.height / 2 - newLoadOffset && !topReached) {
      var (topReached, error) = await loadNewMessagesTop();
      if (!error) {
        this.topReached = topReached;
      }
    } else if (controller!.position.pixels <= newLoadOffset) {
      loadNewMessagesBottom();
    }
  }

  /// Loading state for new messages (at top or bottom)
  final newMessagesLoading = false.obs;

  /// Whether or not the messages are loading at the top (for showing a loading indicator)
  bool messagesLoadingTop = false;

  /// Load new messages from the server for the top of the scroll feed.
  ///
  /// The `first boolean` tells you whether or not the top has been reached.
  /// The `second boolean` tells you whether or not it was still loading or an error happend.
  Future<(bool, bool)> loadNewMessagesTop({int? date}) async {
    if (newMessagesLoading.value || (messages.isEmpty && date == null)) {
      return (false, true);
    }
    messagesLoadingTop = true;
    newMessagesLoading.value = true;
    date ??= messages.last.createdAt.millisecondsSinceEpoch;

    // Load new messages
    final (loadedMessages, error) = await loadMessagesBefore(date);
    if (error) {
      return (false, true);
    }
    if (loadedMessages == null) {
      return (true, false);
    }
    messages.addAll(loadedMessages);

    newMessagesLoading.value = false;
    return (false, false);
  }

  /// Load new messages at the bottom of the scroll feed from the server.
  ///
  /// Returns whether or not it was successful.
  /// Will open an error dialog in case something goes wrong on the server.
  Future<bool> loadNewMessagesBottom() async {
    if (newMessagesLoading.value || messages.isEmpty) {
      return false;
    }
    messagesLoadingTop = false;
    newMessagesLoading.value = true; // We'll use the same loading as above to make sure this doesn't break anything
    final firstMessage = messages.first;

    // Process the messages
    final (loadedMessages, error) = await loadMessagesAfter(firstMessage.createdAt.millisecondsSinceEpoch);
    if (error || loadedMessages == null) {
      return true;
    }
    for (var message in loadedMessages) {
      message.heightCallback = true;
    }
    sendLog(loadedMessages.length);
    loadedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort to prevent weird order
    messages.insertAll(0, loadedMessages);

    newMessagesLoading.value = false;
    return true;
  }

  /// Scroll to a message (only animated when message is loaded in cache).
  ///
  /// Loads the message from the server if it is not in the cache and refreshes
  /// the complete feed in that case.
  Future<bool> scrollToMessage(String id) async {
    // Check if message is already on screen
    var message = messages.firstWhereOrNull((msg) => msg.id == id);
    if (message != null) {
      controller!.scrollToIndex(messages.indexOf(message) + 1);
      if (message.highlightAnimation == null) {
        // If the message is not yet rendered do it through a callback
        message.highlightCallback = () {
          Timer(Duration(milliseconds: 500), () {
            message!.highlightAnimation!.value = 0;
            message.highlightAnimation!.animateTo(1);
          });
        };
      } else {
        // If it is rendered, don't do it through a callback
        message.highlightAnimation!.value = 0;
        message.highlightAnimation!.animateTo(1);
      }
      return true;
    }

    // If message is not on screen, load it dynamically from the database
    message = await loadMessageFromServer(id);
    if (message == null) {
      return false;
    }

    // Add the message to the feed and remove all the others
    messages.clear();
    messages.add(message);

    // Highlight the message
    message.highlightCallback = () {
      Timer(Duration(milliseconds: 500), () {
        message!.highlightAnimation!.value = 0;
        message.highlightAnimation!.animateTo(1);
      });
    };

    // Load the messages below
    await loadNewMessagesBottom();

    return true;
  }

  /// This method should load new messages after the specified unix timestamp.
  ///
  /// The boolean in the tuple should indicate whether and error happend or not.
  Future<(List<Message>?, bool)> loadMessagesAfter(int time);

  /// This method should load new messages before the specified unix timestamp.
  ///
  /// The boolean in the tuple should indicate whether and error happend or not.
  ///
  /// If the list is returned as empty and no error happened, the message provider
  /// will assume the top has been reached.
  Future<(List<Message>?, bool)> loadMessagesBefore(int time);

  /// This method should load a message from the server by id.
  ///
  /// If the message is null, an error occured.
  Future<Message?> loadMessageFromServer(String id, {bool init = true});
}

class Message {
  final String id;
  MessageType type;
  String content;
  List<String> attachments;
  final verified = true.obs;
  String answer;
  final LPHAddress sender;
  final LPHAddress senderAddress;
  final DateTime createdAt;
  final LPHAddress conversation;
  final bool edited;

  Function()? highlightCallback;
  AnimationController? highlightAnimation;
  final canScroll = false.obs;
  double? currentHeight;
  GlobalKey? heightKey;
  bool heightReported = false;
  bool heightCallback = false;
  bool renderingAttachments = false;
  final attachmentsRenderer = <AttachmentContainer>[];
  Message? answerMessage;

  /// Extracts and decrypts the attachments
  Future<bool> initAttachments(MessageProvider provider) async {
    //* Load answer
    if (answer != "") {
      final message = await provider.loadMessageFromServer(answer, init: false);
      answerMessage = message;
    } else {
      answerMessage = null;
    }

    //* Load attachments
    if (attachmentsRenderer.isNotEmpty || renderingAttachments) {
      return true;
    }
    renderingAttachments = true;
    if (attachments.isNotEmpty && type != MessageType.system) {
      for (var attachment in attachments) {
        if (attachment.isURL) {
          final container = AttachmentContainer.remoteImage(attachment);
          await container.init();
          attachmentsRenderer.add(container);
          continue;
        }
        final json = jsonDecode(attachment);
        final type = await AttachmentController.checkLocations(json["i"], StorageType.temporary);
        final container = Get.find<AttachmentController>().fromJson(type, json);
        if (!await container.existsLocally()) {
          final extension = container.id.split(".").last;
          if (FileSettings.imageTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadImages]!.getValue();
            if (download) {
              Get.find<AttachmentController>().downloadAttachment(container);
            }
          } else if (FileSettings.videoTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadVideos]!.getValue();
            if (download) {
              Get.find<AttachmentController>().downloadAttachment(container);
            }
          } else if (FileSettings.audioTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadAudio]!.getValue();
            if (download) {
              Get.find<AttachmentController>().downloadAttachment(container);
            }
          }
        }
        attachmentsRenderer.add(container);
      }
      renderingAttachments = false;
    }

    return true;
  }

  //* Animation when a new message enters the chat
  bool playAnimation = false;
  AnimationController? controller;
  void initAnimation(TickerProvider provider) {
    if (controller != null) {
      return;
    }

    controller = AnimationController(vsync: provider, duration: Duration(milliseconds: 250));
    Timer(Duration(milliseconds: 250), () {
      controller!.forward(from: 0);
    });
  }

  Message(
    this.id,
    this.type,
    this.content,
    this.answer,
    this.attachments,
    this.sender,
    this.senderAddress,
    this.createdAt,
    this.conversation,
    this.edited,
    bool verified,
  ) {
    this.verified.value = verified;
  }

  /// Loads the content from the message (signature, type, content)
  void loadContent({Map<String, dynamic>? json}) {
    final contentJson = json ?? jsonDecode(content);
    if (type != MessageType.system) {
      type = MessageType.values[contentJson["t"] ?? 0];
      if (type == MessageType.text) {
        content = contentJson["c"];
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
  void verifySignature(SymmetricSequencedInfo info, [Sodium? sodium]) async {
    final conversation = Get.find<ConversationController>().conversations[this.conversation]!;
    sendLog("${conversation.members} | ${this.sender}");
    final sender = await Get.find<UnknownController>().loadUnknownProfile(conversation.members[this.sender]!.address);
    if (sender == null) {
      sendLog("NO SENDER FOUND");
      verified.value = false;
      return;
    }
    verified.value = info.verifySignature(sender.signatureKey, sodium);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }

  /// Decrypts the account ids of a system message
  void decryptSystemMessageAttachments([Conversation? conv, SecureKey? key, Sodium? sodium]) {
    conv ??= Get.find<ConversationController>().conversations[conversation]!;
    for (var i = 0; i < attachments.length; i++) {
      if (attachments[i].startsWith("a:")) {
        attachments[i] = jsonDecode(decryptSymmetric(attachments[i].substring(2), key ?? conv.key, sodium))["id"];
      }
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
      "token": token.toMap(),
      "data": id,
    });
    sendLog(json);

    if (!json["success"]) {
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