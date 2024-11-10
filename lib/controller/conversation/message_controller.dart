import 'dart:async';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
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

    // Make sure the thing has some messages in it
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

  /// Store the message in the cache if it is the current selected conversation.
  ///
  /// Also handles system messages.
  void storeMessage(Message message, Conversation conversation) async {
    // Update message reading
    Get.find<ConversationController>().updateMessageRead(
      conversation.id,
      increment: currentProvider.value?.conversation.id != conversation.id,
      messageSendTime: message.createdAt.millisecondsSinceEpoch,
    );

    // Play a notification sound when a new message arrives
    RingingManager.playNotificationSound();

    // Add message to message history if it's the selected one
    if (currentProvider.value?.conversation.id == conversation.id) {
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
      SystemMessages.messages[message.content]?.handle(message, currentProvider.value!);
    }

    // On call message type, ring using the message TODO: Reintroduce the ringtone in Spaces
    /*
    if (message.type == MessageType.call && message.senderAddress != StatusController.ownAddress) {
      final container = SpaceConnectionContainer.fromJson(jsonDecode(message.content));
      RingingManager.startRinging(conversation, container);
    }
    */
  }
}

/// A message provider that loads messages from a conversation.
class ConversationMessageProvider extends MessageProvider {
  final Conversation conversation;
  ConversationMessageProvider(this.conversation);

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
            message.decryptSystemMessageAttachments(keys[0], sodium);
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
          msg.decryptSystemMessageAttachments(keys[0], sodium);
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
        DateTime.fromMillisecondsSinceEpoch(json["creation"]), json["edited"], false);

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

  @override
  Future<String?> deleteMessage(Message message) async {
    // Check if the message is sent by the user
    final token = Get.find<ConversationController>().conversations[conversation.id]!.token;
    if (message.sender != token.id) {
      return "no.permission".tr;
    }

    // Send a request to the server
    final json = await postNodeJSON("/conversations/message/delete", {
      "token": token.toMap(),
      "data": message.id,
    });
    sendLog(json);

    if (!json["success"]) {
      return json["error"];
    }

    return null;
  }

  @override
  Future<bool> deleteMessageFromClient(String id) async {
    messages.removeWhere((element) => element.id == id);
    return true;
  }

  @override
  SecureKey encryptionKey() {
    return conversation.key;
  }

  @override
  Future<(String, int)?> getTimestamp() async {
    // Grab a new timestamp from the server
    var json = await postNodeJSON("/conversations/timestamp", {
      "token": conversation.token.toMap(),
    });
    if (!json["success"]) {
      return null;
    }

    // The stamp is first casted to a num to prevent an error (don't remove)
    return (json["token"] as String, (json["stamp"] as num).toInt());
  }

  @override
  Future<String?> handleMessageSend(String timeToken, String data) async {
    // Send message to the server with conversation token as authentication
    final json = await postNodeJSON("/conversations/message/send", <String, dynamic>{
      "token": conversation.token.toMap(),
      "data": {
        "token": timeToken,
        "data": data,
      }
    });

    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }
}
