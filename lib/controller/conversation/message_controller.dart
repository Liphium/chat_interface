import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/conversation_page.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
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

  /// Unselect a conversation (when id is set, the current conversation will only be closed if it has that id)
  void unselectConversation({LPHAddress? id}) {
    if (id != null && currentProvider.value?.conversation.id != id) {
      return;
    }
    currentProvider.value?.messages.clear();
    currentProvider.value = null;
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
    currentProvider.value = ConversationMessageProvider(conversation);
    if (isMobileMode()) {
      Get.to(ConversationPage(provider: currentProvider.value!));
    }
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      overwriteRead(conversation);
    }

    // Load messages
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
        if (currentProvider.value!.messages.isNotEmpty && currentProvider.value!.messages[0].id != message.id) {
          currentProvider.value!.addMessageToBottom(message);
        } else if (currentProvider.value!.messages.isEmpty) {
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
    final message = await ConversationMessageProvider.unpackMessageInIsolate(conversation, json["message"]);
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
          final (message, info) = ConversationMessageProvider.messageFromJson(
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

  /// Unpack a message json in an isolate.
  ///
  /// Also verifies the signature (but that happens in the main isolate).
  ///
  /// For the future also: TODO: Unpack the signature in a different isolate
  static Future<Message> unpackMessageInIsolate(Conversation conv, Map<String, dynamic> json) async {
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
        final (msg, info) = messageFromJson(
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
  static (Message, SymmetricSequencedInfo?) messageFromJson(Map<String, dynamic> json, {Conversation? conversation, SecureKey? key, Sodium? sodium}) {
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
}
