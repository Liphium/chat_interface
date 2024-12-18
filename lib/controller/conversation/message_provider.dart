import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sodium_libs/sodium_libs.dart';

// Package this and message sending as one
part 'message_sending.dart';

abstract class MessageProvider {
  final messages = <Message>[].obs;
  final waitingMessages = <String>[]; // To prevent messages from being sent twice due to a race condition

  //* Scroll
  static const newLoadOffset = 200;
  bool topReached = false;
  AutoScrollController? controller;

  Future<void> addMessageToBottom(Message message, {bool animation = true}) async {
    // Reset the time of the message at the bottom
    lastMessage = null;

    // Make sure the message is fit for the bottom
    if (messages.isNotEmpty && message.createdAt.isBefore(messages[0].createdAt)) {
      sendLog("TODO: Reload the message list");
      return;
    }

    // Check if there are any messages with similar ids to prevent adding the same message again
    if (waitingMessages.any((msg) => msg == message.id) || messages.any((msg) => msg.id == message.id)) {
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
  Future<void> checkCurrentScrollHeight() async {
    // Get.height is in there because there is a little bit of buffer above
    if (controller == null) {
      return;
    }
    if (controller!.position.pixels > controller!.position.maxScrollExtent - Get.height / 2 - newLoadOffset && !topReached) {
      var (topReached, error) = await loadNewMessagesTop();
      if (!error) {
        this.topReached = topReached;
      }
    } else if (controller!.position.pixels <= newLoadOffset) {
      unawaited(loadNewMessagesBottom());
    }
  }

  /// Loading state for new messages (at top or bottom)
  final newMessagesLoading = false.obs;

  /// Whether or not the messages are loading at the top (for showing a loading indicator)
  bool messagesLoadingTop = false;

  /// The timestamp of the last message at the bottom (for preventing too many requests)
  int? lastMessage;

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
      newMessagesLoading.value = false;
      return (false, true);
    }
    if (loadedMessages == null) {
      newMessagesLoading.value = false;
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
    final time = firstMessage.createdAt.millisecondsSinceEpoch;

    // Make sure this isn't a message that has returned no messages before
    if (lastMessage == time) {
      newMessagesLoading.value = false;
      return true;
    }

    // Process the messages
    final (loadedMessages, error) = await loadMessagesAfter(time);
    if (error || loadedMessages == null) {
      if (loadedMessages == null) {
        lastMessage = time;
      }
      newMessagesLoading.value = false;
      return true;
    }
    for (var message in loadedMessages) {
      message.heightCallback = true;
    }
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
      unawaited(controller!.scrollToIndex(messages.indexOf(message) + 1));
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
        unawaited(message.highlightAnimation!.animateTo(1));
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

  /// Send a text message with files attached.
  /// The files will be uploaded to the server automatically.
  ///
  /// Returns an error or null if successful.
  Future<String?> sendTextMessageWithFiles(
    RxBool loading,
    String message,
    List<UploadData> files,
    String answer,
  ) async {
    if (loading.value) {
      return "error.message.loading";
    }
    loading.value = true;

    // Upload files
    final attachments = <String>[];
    for (var file in files) {
      final res = await Get.find<AttachmentController>().uploadFile(file, StorageType.temporary, Constants.fileAttachmentTag);
      if (res.container == null) {
        return res.message;
      }
      await res.container!.precalculateWidthAndHeight();
      attachments.add(res.data);
    }

    loading.value = false;
    return sendMessage(loading, MessageType.text, attachments, message, answer);
  }

  /// Send a message into the channel of the message provider.
  ///
  /// Returns an error or null if successful.
  Future<String?> sendMessage(
    RxBool loading,
    MessageType type,
    List<String> attachments,
    String message,
    String answer,
  ) async {
    if (message.isEmpty && attachments.isEmpty) {
      return 'error.message.empty'.tr;
    }
    loading.value = true;

    // Upload all the files in case it is a text message
    if (type == MessageType.text) {
      // Scan for links with remote images (and add them as attachments)
      if (attachments.isEmpty) {
        for (var line in message.split("\n")) {
          bool found = false;
          for (var word in line.split(" ")) {
            if (word.isURL) {
              for (var fileType in FileSettings.imageTypes) {
                if (word.endsWith(".$fileType")) {
                  attachments.add(word);
                  if (message.trim() == word) {
                    message = "";
                  }
                  found = attachments.length > 3;
                  break;
                }
              }
              if (found) {
                break;
              }
            }
          }
          if (found) {
            break;
          }
        }
      }
    }

    // Grab a new timestamp from the server
    var obj = await getTimestamp();
    if (obj == null) {
      return "error.message.timestamp".tr;
    }

    // Use the timestamp from the json (to prevent desynchronization and stuff)
    final (timeToken, stamp) = obj;
    final content = Message.buildContentJson(
      content: message,
      type: type,
      attachments: attachments,
      answerId: answer,
    );

    // Encrypt message with signature
    final info = SymmetricSequencedInfo.builder(content, stamp).finish(encryptionKey());

    // Send message
    final error = await handleMessageSend(timeToken, info);
    if (error != null) {
      loading.value = false;
      return error;
    }
    return null;
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

  /// This method deletes a message only from the client by id.
  Future<bool> deleteMessageFromClient(String id);

  /// This method deletes a message from the server and client.
  ///
  /// Returns an error if there is one.
  Future<String?> deleteMessage(Message message);

  /// This method gets a timestamp token and the time in unix from the server.
  ///
  /// This helps prevent inconsistent time on the client and makes sure the message order is proper.
  Future<(String, int)?> getTimestamp();

  /// This method should get the encryption key of the message provider.
  SecureKey encryptionKey();

  /// This method is called with an encrypted string that contains the entire message.
  /// This method should send this data to the server as the message.
  ///
  /// This method should return an error or null if it was successful.
  Future<String?> handleMessageSend(String timeToken, String data);
}

class Message {
  final String id;
  MessageType type;
  String content;
  List<String> attachments;
  final verified = true.obs;
  String answer;
  final LPHAddress senderToken;
  final LPHAddress senderAddress;
  final DateTime createdAt;
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
              await Get.find<AttachmentController>().downloadAttachment(container, ignoreLimit: false);
            }
          } else if (FileSettings.videoTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadVideos]!.getValue();
            if (download) {
              await Get.find<AttachmentController>().downloadAttachment(container, ignoreLimit: false);
            }
          } else if (FileSettings.audioTypes.contains(extension)) {
            final download = Get.find<SettingController>().settings[FileSettings.autoDownloadAudio]!.getValue();
            if (download) {
              await Get.find<AttachmentController>().downloadAttachment(container, ignoreLimit: false);
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

  Message({
    required this.id,
    required this.type,
    required this.content,
    required this.answer,
    required this.attachments,
    required this.senderToken,
    required this.senderAddress,
    required this.createdAt,
    required this.edited,
    required bool verified,
  }) {
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

  /// Convert content to a message content json
  static String buildContentJson({
    required String content,
    required MessageType type,
    required List<String> attachments,
    required String answerId,
  }) {
    return jsonEncode(<String, dynamic>{
      "c": content,
      "t": type.index,
      "a": attachments,
      "r": answerId, // the "r" stands for reply
    });
  }

  /// Convert current message to a content json
  String toContentJson() {
    return buildContentJson(content: content, type: type, attachments: attachments, answerId: answer);
  }

  /// Verifies the signature of the message
  Future<bool> verifySignature(SymmetricSequencedInfo info, [Sodium? sodium]) async {
    final sender = await Get.find<UnknownController>().loadUnknownProfile(senderAddress);
    if (sender == null) {
      sendLog("NO SENDER FOUND");
      verified.value = false;
      return false;
    }
    verified.value = info.verifySignature(sender.signatureKey, sodium);
    return true;
  }

  /// Decrypts the account ids of a system message
  void decryptSystemMessageAttachments(SecureKey key, Sodium sodium) {
    for (var i = 0; i < attachments.length; i++) {
      if (attachments[i].startsWith("a:")) {
        attachments[i] = jsonDecode(decryptSymmetric(attachments[i].substring(2), key, sodium))["id"];
      }
    }
  }

  /// Delete message on the server (and on the client)
  ///
  /// Returns null if successful, otherwise an error message
  Future<String?> delete(MessageProvider provider) async {
    await provider.deleteMessage(this);
    return null;
  }
}

enum MessageType {
  text,
  system,
  call,
  liveshare;
}
