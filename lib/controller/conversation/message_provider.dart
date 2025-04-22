import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/services/chat/unknown_service.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
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
import 'package:lorien_chat_list/chat_list_controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sodium_libs/sodium_libs.dart';

// Package this and message sending as one
part 'message_sending.dart';

abstract class MessageProvider {
  final messages = mapSignal(<String, Message>{});
  final waitingMessages = <String>[]; // To prevent messages from being sent twice due to a race condition

  //* Scroll
  static const newLoadOffset = 200;
  bool topReached = false;
  AutoScrollController? _scrollController;
  ChatListController<String> listController = ChatListController<String>(initialItems: []);

  /// Helper method to get the newest message
  String? getNewestMessage() {
    return getMessageIdAfter(_getOrderedList(), 0, 1);
  }

  /// Helper method to get the oldest message
  String? getOldestMessage() {
    return getMessageIdAfter(_getOrderedList(), listController.itemsCount - 1, -1);
  }

  /// Helper function to make sure the message returned actually exists
  String? getMessageIdAfter(List<String> list, int index, int direction) {
    while (messages[list[index]] == null) {
      index += direction;
    }
    return list[index];
  }

  /// Helper method to get the index
  int? getIndexOf(String messageId) {
    // Determine the index of the message
    int index = 0;
    for (var id in _getOrderedList()) {
      if (id == messageId) {
        break;
      }
      index++;
    }

    return index;
  }

  /// Returns the ID of the message immediately before the one at [index], or null if out of bounds.
  String? getPreviousMessageId(int index) {
    final allIds = _getOrderedList();
    if (index <= 0 || index >= allIds.length) return null;

    return getMessageIdAfter(allIds, index - 1, -1);
  }

  /// Returns the ID of the message immediately next to the one at [index], or null if out of bounds.
  String? getNextMessageId(int index) {
    final allIds = _getOrderedList();
    if (index < 0 || index >= allIds.length - 1) return null;

    return getMessageIdAfter(allIds, index + 1, 1);
  }

  /// Helper function to get the complete list
  List<String> _getOrderedList() {
    return listController.newItems.reversed.toList() + listController.oldItems;
  }

  Future<void> addMessageToBottom(Message message, {bool animation = true}) async {
    // Update the last message date
    lastMessage = message.createdAt.millisecondsSinceEpoch;

    // Make sure the message is fit for the bottom
    final lastAdded = messages[getNewestMessage()];
    if (messages.isNotEmpty && lastAdded != null) {
      if (lastAdded.createdAt.isAfter(message.createdAt)) {
        sendLog("TODO: Reload the message list ${lastAdded.content}");
        return;
      }
    }

    sendLog("last added: ${lastAdded?.content}, most old: ${messages[getOldestMessage()!]?.content}");

    sendLog("adding message with id ${message.id} ${messages[message.id]?.content}");

    // Check if there are any messages with similar ids to prevent adding the same message again
    if (waitingMessages.any((msg) => msg == message.id) || messages[message.id] != null) {
      return;
    }
    waitingMessages.add(message.id);

    // Initialize all message data
    await message.initAttachments(this);

    // Only load the message, if scrolled near enough to the bottom
    if (_scrollController!.position.pixels <= newLoadOffset) {
      messages[message.id] = message;
      listController.addToBottom(message.id);
    }

    // Remove after cause then it is added
    waitingMessages.remove(message.id);
  }

  void newControllers(AutoScrollController newScroll) {
    if (_scrollController != null) {
      _scrollController!.removeListener(checkCurrentScrollHeight);
    }
    _scrollController = newScroll;
    _scrollController!.addListener(checkCurrentScrollHeight);
  }

  /// Runs on every scroll to check if new messages should be loaded
  Future<void> checkCurrentScrollHeight() async {
    if (_scrollController!.position.pixels <= newLoadOffset &&
        _scrollController!.position.pixels != 0 &&
        !listController.shouldScrollToBottom) {
      unawaited(loadNewMessagesBottom());
    }
  }

  /// Loading state for new messages (at top or bottom)
  final newMessagesLoading = signal(false);

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
    date ??= messages[getOldestMessage()]!.createdAt.millisecondsSinceEpoch;

    sendLog("do request with $date ${DateTime.now().millisecondsSinceEpoch}");

    // Load new messages
    final (loadedMessages, error) = await loadMessagesBefore(date);
    if (error) {
      newMessagesLoading.value = false;
      sendLog("error");
      return (false, true);
    }
    newMessagesLoading.value = false;
    if (loadedMessages == null) {
      sendLog("no messages");
      return (true, false);
    }
    batch(() {
      for (var msg in loadedMessages) {
        messages[msg.id] = msg;
      }
      listController.addRangeToTop(loadedMessages.map((m) => m.id).toList());
    });

    sendLog("success loading top ${newMessagesLoading.value} ${loadedMessages.length}");

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
    newMessagesLoading.value = true; // Same loading state as above to not break anything
    final firstMessage = messages[getNewestMessage()]!;
    final time = firstMessage.createdAt.millisecondsSinceEpoch;

    // Make sure we're not requesting the same messages again
    if (lastMessage == time) {
      newMessagesLoading.value = false;
      return true;
    }
    lastMessage = time;

    sendLog("loading bottom with ${firstMessage.content}");

    // Process the messages
    final (loadedMessages, error) = await loadMessagesAfter(time);
    if (error || loadedMessages == null) {
      newMessagesLoading.value = false;
      return true;
    }
    for (var message in loadedMessages) {
      message.heightCallback = true;
    }
    loadedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort to prevent weird order
    batch(() {
      for (var msg in loadedMessages) {
        messages[msg.id] = msg;
      }
      listController.addRangeToBottom(loadedMessages.map((m) => m.id).toList());
    });

    newMessagesLoading.value = false;
    return true;
  }

  /// Scroll to a message (only animated when message is loaded in cache).
  ///
  /// Loads the message from the server if it is not in the cache and refreshes
  /// the complete feed in that case.
  Future<bool> scrollToMessage(String id) async {
    // Check if message is already on screen
    var message = messages[id];
    if (message != null) {
      unawaited(_scrollController!.scrollToIndex(getIndexOf(message.id)!));
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
    listController.addToTop(message.id);
    messages[message.id] = message;

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
    Signal<bool> loading,
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
      final res = await AttachmentController.uploadFile(file, StorageType.temporary, Constants.fileAttachmentTag);
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
    Signal<bool> loading,
    MessageType type,
    List<String> attachments,
    String message,
    String answer,
  ) async {
    // Check if there is a connection before doing this
    if (!ConnectionController.connected.value) {
      return "error.no_connection".tr;
    }

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
    final content = Message.buildContentJson(content: message, type: type, attachments: attachments, answerId: answer);

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
  final verified = signal(true);
  String answer;
  final LPHAddress senderToken;
  final LPHAddress senderAddress;
  final DateTime createdAt;
  final bool edited;

  Function()? highlightCallback;
  AnimationController? highlightAnimation;
  final canScroll = signal(false);
  double? currentHeight;
  GlobalKey? heightKey;
  bool heightReported = false;
  bool heightCallback = false;
  bool renderingAttachments = false;
  final attachmentsRenderer = <AttachmentContainer>[];
  Message? answerMessage;

  /// Extracts and decrypts the attachments
  Future<bool> initAttachments(MessageProvider? provider) async {
    // Load answer
    if (answer != "" && provider != null) {
      final message = await provider.loadMessageFromServer(answer, init: false);
      answerMessage = message;
    } else {
      answerMessage = null;
    }

    // Load attachments
    if (attachmentsRenderer.isNotEmpty || renderingAttachments) {
      return true;
    }
    renderingAttachments = true;
    if (attachments.isNotEmpty && type != MessageType.system) {
      for (var attachment in attachments) {
        // Parse the attachment to the container
        final container = await AttachmentController.fromString(attachment);

        // Make sure to properly handle remote containers (both links and remote images)
        if (container.attachmentType != AttachmentContainerType.file) {
          await container.init();
          attachmentsRenderer.add(container);
          continue;
        }

        // Check if the container should be downloaded automatically
        if (!await container.existsLocally()) {
          final extension = container.id.split(".").last;
          if (FileSettings.imageTypes.contains(extension)) {
            final download = SettingController.settings[FileSettings.autoDownloadImages]!.getValue();
            if (download) {
              await AttachmentController.downloadAttachment(container, ignoreLimit: false);
            }
          } else if (FileSettings.videoTypes.contains(extension)) {
            final download = SettingController.settings[FileSettings.autoDownloadVideos]!.getValue();
            if (download) {
              await AttachmentController.downloadAttachment(container, ignoreLimit: false);
            }
          } else if (FileSettings.audioTypes.contains(extension)) {
            final download = SettingController.settings[FileSettings.autoDownloadAudio]!.getValue();
            if (download) {
              await AttachmentController.downloadAttachment(container, ignoreLimit: false);
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
    final sender = await UnknownService.loadUnknownProfile(senderAddress);
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

enum MessageType { text, system, call, liveshare }
