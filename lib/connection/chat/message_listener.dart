import 'dart:async';

import 'package:chat_interface/connection/connection.dart' as cn;
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class MessageListener {
  /// Register all the event handlers required for message receiving.
  static void setupMessageListener() {
    // Listen for one message
    cn.connector.listen("conv_msg", (event) async {
      sendLog("received one message");
      // Check if the conversation even exists on this account
      final conversation = Get.find<ConversationController>().conversations[LPHAddress.from(event.data["msg"]["cv"])];
      if (conversation == null) {
        sendLog("WARNING: invalid message, conversation not found");
        return;
      }

      // Unpack the message in a different isolate (to prevent lag)
      final message = await unpackMessageInIsolate(conversation, event.data["msg"]);

      // Check if there are too many attachments
      if (message.attachments.length > 5) {
        sendLog("WARNING: invalid message, more than 5 attachments");
        return;
      }

      // Tell the controller about the message in a different isolate
      unawaited(Get.find<MessageController>().storeMessage(message, conversation));
    });

    // Listen for multiple messages (mp stands for multiple)
    cn.connector.listen(
      "conv_msg_mp",
      (event) async {
        // Check if the conversation even exists on this account
        final conversation = Get.find<ConversationController>().conversations[LPHAddress.from(event.data["cv"])];
        if (conversation == null) {
          sendLog("WARNING: invalid message, conversation not found");
          return;
        }

        // Unpack all of the messages in an isolate
        final messages = await unpackMessagesInIsolate(conversation, event.data["msgs"], includeSystemMessages: true);

        // Remove all messages with more than 5 attachments
        messages.removeWhere((msg) {
          if (msg.attachments.length > 5) {
            sendLog("WARNING: invalid message received, dropping it (attachments > 5)");
            return true;
          }

          return false;
        });

        // Store all of the messages in the local database
        unawaited(Get.find<MessageController>().storeMessages(messages, conversation));
      },
    );
  }

  /// Unpack a message json in an isolate.
  ///
  /// Also verifies the signature (but that happens in the main isolate).
  ///
  /// For the future also: TODO: Unpack the signature in a different isolate
  static Future<Message> unpackMessageInIsolate(Conversation conv, Map<String, dynamic> json) async {
    // Run an isolate to parse the message
    final copy = Conversation.copyWithoutKey(conv);
    final (message, info) = await sodiumLib.runIsolated(
      (sodium, keys, pairs) {
        // Unpack the actual message
        final (msg, info) = messageFromJson(
          json,
          sodium: sodium,
          key: keys[0],
          conversation: copy,
        );

        // Unpack the system message attachments in case needed
        if (msg.type == MessageType.system) {
          msg.decryptSystemMessageAttachments(keys[0], sodium);
        }

        // Return it to the main isolate
        return (msg, info);
      },
      secureKeys: [conv.key],
    );

    // Verify the signature
    if (info != null) {
      await message.verifySignature(info);
    }

    return message;
  }

  /// Process a message payload from the server in an isolate.
  ///
  /// All the json decoding and decryption is running in one isolate, only the verification of
  /// the signature is ran in the main isolate due to constraints with libsodium.
  ///
  /// For the future: TODO: Also process the signatures in the isolate by preloading profiles
  static Future<List<Message>> unpackMessagesInIsolate(Conversation conversation, List<dynamic> json, {bool includeSystemMessages = false}) async {
    // Unpack the messages in an isolate (in a separate thread yk)
    final copy = Conversation.copyWithoutKey(conversation);
    final loadedMessages = await sodiumLib.runIsolated(
      (sodium, keys, pairs) async {
        // Process all messages
        final list = <(Message, SymmetricSequencedInfo?)>[];
        for (var msgJson in json) {
          final (message, info) = messageFromJson(
            msgJson,
            conversation: copy,
            key: keys[0],
            sodium: sodium,
          );

          // Don't render system messages that shouldn't be rendered (this is only for safety, should never actually happen)
          if (message.type == MessageType.system && SystemMessages.messages[message.content]?.render == false && !includeSystemMessages) {
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

    // Verify the signature of all messages
    for (var (msg, info) in loadedMessages) {
      if (info != null) {
        await msg.verifySignature(info);
      }
    }

    return loadedMessages.map((tuple) => tuple.$1).toList();
  }

  /// Load a message from json (from the server) and get the corresponding [SymmetricSequencedInfo] (only if no system message).
  ///
  /// **Doesn't verify the signature**
  static (Message, SymmetricSequencedInfo?) messageFromJson(Map<String, dynamic> json, {Conversation? conversation, SecureKey? key, Sodium? sodium}) {
    // Convert to message
    conversation ??= Get.find<ConversationController>().conversations[json["cv"]]!;
    final senderAddress = LPHAddress.from(json["sr"]);
    final message = Message(
      id: json["id"],
      type: MessageType.text,
      content: json["dt"],
      answer: "",
      attachments: [],
      senderToken: senderAddress,
      senderAddress: conversation.members[senderAddress]?.address ?? LPHAddress("-", "removed".tr),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json["ct"]),
      edited: json["ed"],
      verified: false,
    );

    // Make sure to not decrypt when it is a system message
    if (message.senderToken == MessageController.systemSender) {
      message.verified.value = true; // No verification needed, valid since from the server
      message.type = MessageType.system;
      message.loadContent();
      return (message, null);
    }

    // Decrypt the content of the message
    final info = SymmetricSequencedInfo.extract(message.content, key ?? conversation.key, sodium);
    message.content = info.text;
    message.loadContent();

    return (message, info);
  }
}
