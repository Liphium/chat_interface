import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/conversation_page.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sodium_libs/sodium_libs.dart';

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

  /// Unselect a conversation (when id is set, the current conversation will only be closed if it has that id)
  void unselectConversation({String? id}) {
    if (id != null && currentConversation.value?.id != id) {
      return;
    }
    currentConversation.value = null;
    messages.clear();
  }

  void openTab(OpenTabType type) {
    currentOpenType.value = type;
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
    loadNewMessagesTop(date: DateTime.now().millisecondsSinceEpoch);

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

  /// Delete a message from the client with an id
  void deleteMessageFromClient(String conversation, String id) async {
    // Check if message is in the selected conversation
    if (currentConversation.value?.id == conversation) {
      messages.removeWhere((element) => element.id == id);
    }
  }

  /// Store the message in the cache if it is the current selected conversation.
  ///
  /// Also handles system messages.
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

    // Handle system messages
    if (message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message);
    }
  }

  //* Scroll
  static const newLoadOffset = 200;
  bool topReached = false;
  late AutoScrollController controller;
  final waitingMessages = <String>[]; // To prevent messages from being sent twice due to a race condition

  void addMessageToBottom(Message message, {bool animation = true}) async {
    // Check if there are any messages with similar ids to prevent adding the same message again
    if (waitingMessages.any((msg) => msg == message.id)) {
      return;
    }
    waitingMessages.add(message.id);

    // Initialize all message data
    await message.initAttachments();
    waitingMessages.remove(message.id); // Remove after cause then it is added

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

  void newScrollController(AutoScrollController newController) {
    controller = newController;
    controller.addListener(() => checkCurrentScrollHeight());
  }

  /// Runs on every scroll to check if new messages should be loaded
  void checkCurrentScrollHeight() async {
    // Get.height is in there because there is a little bit of buffer above
    if (controller.position.pixels > controller.position.maxScrollExtent - Get.height / 2 - newLoadOffset && !topReached) {
      var (topReached, error) = await loadNewMessagesTop();
      if (!error) {
        this.topReached = topReached;
      }
    } else if (controller.position.pixels <= newLoadOffset) {
      sendLog("load bottom");
      loadNewMessagesBottom();
    }
  }

  /// Loading state for new messages (at top or bottom)
  bool loading = false;

  /// Load new messages from the server for the top of the scroll feed.
  ///
  /// The `first boolean` tells you whether or not the top has been reached.
  /// The `second boolean` tells you whether or not it was still loading or an error happend.
  Future<(bool, bool)> loadNewMessagesTop({int? date}) async {
    if (loading || (messages.isEmpty && date == null)) {
      return (false, true);
    }
    loading = true;
    date ??= messages.last.createdAt.millisecondsSinceEpoch;

    // Load the messages from the server using the list_before endpoint
    final conversation = currentConversation.value!;
    final json = await postNodeJSON("/conversations/message/list_before", {
      "token_id": conversation.token.id,
      "token": conversation.token.token,
      "before": date,
    });

    // Check if there was an error
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      loading = false;
      return (false, false);
    }

    // Check if the top has been reached
    if (json["messages"] == null || json["messages"].isEmpty) {
      loading = false;
      return (true, false);
    }

    // Unpack the messages in an isolate (in a separate thread yk)
    final loadedMessages = await _processMessages(conversation, json["messages"]);
    messages.addAll(loadedMessages);

    loading = false;
    return (false, false);
  }

  /// Load new messages at the bottom of the scroll feed from the server.
  ///
  /// Returns whether or not it was successful.
  /// Will open an error dialog in case something goes wrong on the server.
  Future<bool> loadNewMessagesBottom() async {
    if (loading || messages.isEmpty) {
      sendLog("loading or sth");
      return false;
    }
    loading = true; // We'll use the same loading as above to make sure this doesn't break anything
    final firstMessage = messages.first;

    sendLog(messages.first.createdAt.toIso8601String());

    // Load messages from the server
    final conversation = currentConversation.value!;
    final json = await postNodeJSON("/conversations/message/list_after", {
      "token_id": conversation.token.id,
      "token": conversation.token.token,
      "after": firstMessage.createdAt.millisecondsSinceEpoch,
    });

    // Check if there was an error
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      loading = false;
      return false;
    }

    // Check if the top has been reached
    if (json["messages"].isEmpty) {
      loading = false;
      return false;
    }

    // Process the messages
    final loadedMessages = await _processMessages(conversation, json["messages"]);
    for (var message in loadedMessages) {
      message.heightCallback = true;
    }
    loadedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort to prevent weird order
    messages.insertAll(0, loadedMessages);

    loading = false;
    return true;
  }

  /// Process a message payload from the server in an isolate.
  ///
  /// All the json decoding and decryption is running in one isolate, only the verification of
  /// the signature is ran in the main isolate due to constraints with libsodium.
  ///
  /// For the future: TODO: Also process the signatures in the isolate by preloading profiles
  Future<List<Message>> _processMessages(Conversation conversation, List<dynamic> json) async {
    // Unpack the messages in an isolate (in a separate thread yk)
    final copy = Conversation.copyWithoutKey(conversation);
    final loadedMessages = await sodiumLib.runIsolated(
      (sodium, keys, pairs) async {
        // Process all messages
        final list = <(Message, SymmetricSequencedInfo?)>[];
        for (var msgJson in json) {
          final (message, info) = Message.fromJson(
            msgJson,
            conversation: copy,
            key: keys[0],
            sodium: sodium,
          );

          // Don't render system messages that shouldn't be rendered (this is only for safety, should never actually happen)
          if (message.type == MessageType.system && SystemMessages.messages[message.content]?.render == false) {
            continue;
          }

          // Decrypt system message attachments
          if (message.type == MessageType.system) {
            message.decryptSystemMessageAttachments(copy, keys[0], sodium);
          }

          list.add((message, info));
        }

        // Return the list to the main isolate
        return list;
      },
      secureKeys: [conversation.key],
    );

    // Init the attachments on all messages and verify signatures
    for (var (msg, info) in loadedMessages) {
      if (info != null) {
        msg.verifySignature(info);
      }
      await msg.initAttachments();
    }

    return loadedMessages.map((tuple) => tuple.$1).toList();
  }

  /// Scroll to a message (only animated when message is loaded in cache).
  ///
  /// Loads the message from the server if it is not in the cache and refreshes
  /// the complete feed in that case.
  Future<bool> scrollToMessage(String id) async {
    // Check if message is already on screen
    var message = messages.firstWhereOrNull((msg) => msg.id == id);
    if (message != null) {
      controller.scrollToIndex(messages.indexOf(message) + 1);
      if (message.highlightAnimation == null) {
        // If the message is not yet rendered do it through a callback
        message.highlightCallback = () {
          Timer(500.ms, () {
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
    message = await Message.loadFromServer(currentConversation.value!, id);
    if (message == null) {
      return false;
    }

    // Add the message to the feed and remove all the others
    messages.clear();
    messages.add(message);

    // Highlight the message
    message.highlightCallback = () {
      Timer(500.ms, () {
        message!.highlightAnimation!.value = 0;
        message.highlightAnimation!.animateTo(1);
      });
    };

    // Load the messages below
    await loadNewMessagesBottom();

    return true;
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
  Future<bool> initAttachments() async {
    //* Load answer
    if (answer != "") {
      final message = await Message.loadFromServer(Get.find<ConversationController>().conversations[conversation]!, answer, init: false);
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

  /// Load a message from the server.
  ///
  /// Uses a different isolate (than the main one) to unpack the message.
  static Future<Message?> loadFromServer(Conversation conversation, String messageId, {init = true}) async {
    // Get the message from the server
    final json = await postNodeJSON("/conversations/message/get", {
      "token_id": conversation.token.id,
      "token": conversation.token.token,
      "message": messageId,
    });

    // Check if there is an error
    if (!json["success"]) {
      sendLog("error fetching message $messageId: ${json["error"]}");
      return null;
    }

    // Parse message and init attachments (if desired)
    final message = await Message.unpackInIsolate(conversation, json["message"]);
    if (init) {
      await message.initAttachments();
    }

    return message;
  }

  /// Unpack a message json in an isolate
  ///
  /// Also verifies the signature (but that happens in the main isolate).
  ///
  /// For the future also: TODO: Unpack the signature in a different isolate
  static Future<Message> unpackInIsolate(Conversation conv, Map<String, dynamic> json) async {
    // Run an isolate to parse the message
    final copy = Conversation.copyWithoutKey(conv);
    final (message, info) = await _extractMessageIsolate(json, copy, conv.key);

    // Verify the signature
    if (info != null) {
      message.verifySignature(info);
    }

    return message;
  }

  static Future<(Message, SymmetricSequencedInfo?)> _extractMessageIsolate(Map<String, dynamic> json, Conversation copied, SecureKey key) {
    return sodiumLib.runIsolated(
      (sodium, keys, pairs) {
        // Unpack the actual message
        final (msg, info) = Message.fromJson(
          json,
          sodium: sodium,
          key: keys[0],
          conversation: copied,
        );

        // Unpack the system message attachments in case needed
        if (msg.type == MessageType.system) {
          msg.decryptSystemMessageAttachments(copied, keys[0], sodium);
        }

        // Return it to the main isolate
        return (msg, info);
      },
      secureKeys: [key],
    );
  }

  /// Load a message from json (from the server) and get the corresponding [SymmetricSequencedInfo] (only if no system message).
  ///
  /// **Doesn't verify the signature**
  static (Message, SymmetricSequencedInfo?) fromJson(Map<String, dynamic> json, {Conversation? conversation, SecureKey? key, Sodium? sodium}) {
    // Convert to message
    final account = (conversation ?? Get.find<ConversationController>().conversations[json["conversation"]]!).members[json["sender"]]?.account ?? "removed";
    var message = Message(json["id"], MessageType.text, json["data"], "", [], json["certificate"], json["sender"], account, DateTime.fromMillisecondsSinceEpoch(json["creation"]), json["conversation"],
        json["edited"], false);

    // Decrypt content
    conversation ??= Get.find<ConversationController>().conversations[json["conversation"]]!;
    if (message.sender == MessageController.systemSender) {
      message.verified.value = true;
      message.type = MessageType.system;
      message.loadContent();
      sendLog("SYSTEM MESSAGE");
      return (message, null);
    }

    // Check signature
    final info = SymmetricSequencedInfo.extract(message.content, key ?? conversation.key, sodium);
    message.content = info.text;
    message.loadContent();

    return (message, info);
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
  void verifySignature(SymmetricSequencedInfo info, [Sodium? sodium]) async {
    final conversation = Get.find<ConversationController>().conversations[this.conversation]!;
    sendLog("${conversation.members} | ${this.sender}");
    final sender = await Get.find<UnknownController>().loadUnknownProfile(conversation.members[this.sender]!.account);
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
