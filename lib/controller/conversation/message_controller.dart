import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/conversation_page.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

enum OpenTabType {
  conversation,
  space,
  townsquare;
}

class MessageController extends GetxController {
  // Constants
  Message? hoveredMessage;
  AttachmentContainer? hoveredAttachment;
  static LPHAddress systemSender = LPHAddress("liphium.com", "6969");

  final loaded = false.obs;
  final currentOpenType = OpenTabType.conversation.obs;
  final currentProvider = Rx<ConversationMessageProvider?>(null);
  final messages = <Message>[].obs;

  /// Unselect a conversation (when id is set, the current conversation will only be closed if it has that id)
  void unselectConversation({LPHAddress? id}) {
    if (id != null && currentProvider.value?.conversation.id != id) {
      return;
    }
    currentProvider.value = null;
    messages.clear();
  }

  void openTab(OpenTabType type) {
    currentOpenType.value = type;
    if (type != OpenTabType.conversation) {
      unselectConversation();
    }
  }

  void selectConversation(Conversation conversation) async {
    currentOpenType.value = OpenTabType.conversation;
    loaded.value = false;
    if (isMobileMode()) {
      Get.to(ConversationPage(conversation: conversation));
    }
    currentProvider.value = ConversationMessageProvider(conversation);
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      overwriteRead(conversation);
    }

    // Load messages
    messages.clear();
    currentProvider.value!.loadNewMessagesTop(date: DateTime.now().millisecondsSinceEpoch);

    loaded.value = true;
  }

  // Push read state to the server
  void overwriteRead(Conversation conversation) async {
    // Send new read state to the server
    final json = await postNodeJSON("/conversations/read", {
      "token": conversation.token.toMap(),
    });
    if (json["success"]) {
      conversation.notificationCount.value = 0;
      conversation.readAt.value = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Delete a message from the client with an id
  void deleteMessageFromClient(LPHAddress conversation, String id) async {
    // Check if message is in the selected conversation
    if (currentProvider.value?.conversation.id == conversation) {
      currentProvider.value?.messages.removeWhere((element) => element.id == id);
    }
  }

  /// Store the message in the cache if it is the current selected conversation.
  ///
  /// Also handles system messages.
  void storeMessage(Message message) async {
    // Update message reading
    Get.find<ConversationController>().updateMessageRead(
      message.conversation,
      increment: currentProvider.value?.conversation.id != message.conversation,
      messageSendTime: message.createdAt.millisecondsSinceEpoch,
    );

    // Play a notification sound when a new message arrives
    RingingManager.playNotificationSound();

    // Add message to message history if it's the selected one
    if (currentProvider.value?.conversation.id == message.conversation) {
      if (message.sender != currentProvider.value?.conversation.token.id) {
        overwriteRead(currentProvider.value!.conversation);
      }

      // Check if it is a system message and if it should be rendered or not
      if (message.type == MessageType.system) {
        if (SystemMessages.messages[message.content]?.render == true) {
          currentProvider.value!.addMessageToBottom(message);
        }
      } else {
        // Store normal type of message
        if (messages.isNotEmpty && messages[0].id != message.id) {
          currentProvider.value!.addMessageToBottom(message);
        } else if (messages.isEmpty) {
          currentProvider.value!.addMessageToBottom(message);
        }
      }
    }

    // Handle system messages
    if (message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message);
    }

    // On call message type, ring using the message
    if (message.type == MessageType.call && message.senderAddress != StatusController.ownAddress) {
      // Get the conversation for the ring
      final conversation = Get.find<ConversationController>().conversations[message.conversation];
      if (conversation == null) {
        return;
      }

      // Decode the message and stuff
      final container = SpaceConnectionContainer.fromJson(jsonDecode(message.content));
      RingingManager.startRinging(conversation, container);
    }
  }
}

/// A message provider that loads messages from a conversation.
class ConversationMessageProvider extends MessageProvider {
  Conversation conversation;
  ConversationMessageProvider(this.conversation);

  void changeConversation(Conversation conv) {
    conversation = conv;
  }

  @override
  Future<(List<Message>?, bool)> loadMessagesBefore(int time) async {
    // Load messages from the server
    final json = await postNodeJSON("/conversations/message/list_after", {
      "token": conversation.token.toMap(),
      "data": time,
    });

    // Check if there was an error
    if (!json["success"]) {
      conversation.error.value = json["error"];
      newMessagesLoading.value = false;
      return (null, true);
    }

    // Check if the top has been reached
    if (json["messages"] == null || json["messages"].isEmpty) {
      newMessagesLoading.value = false;
      return (null, false);
    }

    // Process the messages in a seperate isolate
    return (await _processMessages(json["messages"]), false);
  }

  @override
  Future<(List<Message>?, bool)> loadMessagesAfter(int time) async {
    // Load the messages from the server using the list_before endpoint
    final json = await postNodeJSON("/conversations/message/list_before", {
      "token": conversation.token.toMap(),
      "data": time,
    });

    // Check if there was an error
    if (!json["success"]) {
      conversation.error.value = json["error"];
      newMessagesLoading.value = false;
      return (null, true);
    }

    // Check if the bottom has been reached
    if (json["messages"] == null || json["messages"].isEmpty) {
      newMessagesLoading.value = false;
      return (null, false);
    }

    // Unpack the messages in an isolate
    return (await _processMessages(json["messages"]), false);
  }

  @override
  Future<Message?> loadMessageFromServer(String id, {bool init = true}) async {
    // Get the message from the server
    final json = await postNodeJSON("/conversations/message/get", {
      "token": conversation.token.toMap(),
      "data": id,
    });

    // Check if there is an error
    if (!json["success"]) {
      sendLog("error fetching message $id: ${json["error"]}");
      return null;
    }

    // Parse message and init attachments (if desired)
    final message = await Message.unpackInIsolate(conversation, json["message"]);
    if (init) {
      await message.initAttachments(this);
    }

    return message;
  }

  /// Process a message payload from the server in an isolate.
  ///
  /// All the json decoding and decryption is running in one isolate, only the verification of
  /// the signature is ran in the main isolate due to constraints with libsodium.
  ///
  /// For the future: TODO: Also process the signatures in the isolate by preloading profiles
  Future<List<Message>> _processMessages(List<dynamic> json) async {
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
      await msg.initAttachments(this);
    }

    return loadedMessages.map((tuple) => tuple.$1).toList();
  }
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
    this.sender,
    this.senderAddress,
    this.createdAt,
    this.conversation,
    this.edited,
    bool verified,
  ) {
    this.verified.value = verified;
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
    final senderAddress = LPHAddress.from(json["sender"]);
    final account = (conversation ?? Get.find<ConversationController>().conversations[json["conversation"]]!).members[senderAddress]?.address ??
        LPHAddress("-", "removed".tr);
    var message = Message(json["id"], MessageType.text, json["data"], "", [], senderAddress, account,
        DateTime.fromMillisecondsSinceEpoch(json["creation"]), LPHAddress.from(json["conversation"]), json["edited"], false);

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
