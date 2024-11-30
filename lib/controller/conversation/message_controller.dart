import 'dart:async';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/messages_page.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:drift/drift.dart';

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
      Get.to(MessagesPageMobile(provider: currentProvider.value!));
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

  /// Store the message in the local database and in the cache (if the conversation is selected).
  ///
  /// Also handles system messages.
  void storeMessage(Message message, Conversation conversation, {bool simple = false}) async {
    // Ignore certain things in case they are already done or not needed
    if (!simple) {
      // Update message read time for conversations (nessecary for notification count)
      Get.find<ConversationController>().updateMessageRead(
        conversation.id,
        increment: currentProvider.value?.conversation.id != conversation.id,
        messageSendTime: message.createdAt.millisecondsSinceEpoch,
      );

      // Play a notification sound when a new message arrives
      RingingManager.playNotificationSound();
    }

    // Add message to message history if it's the selected one
    if (currentProvider.value?.conversation.id == conversation.id) {
      if (message.senderToken != currentProvider.value?.conversation.token.id && !simple) {
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

  /// Store all of the messages in the list in the local database.
  ///
  /// This method doesn't play a sound because it's only used for synchronization.
  void storeMessages(List<Message> messages, Conversation conversation) {
    // Sort all the messages to prevent failing system messages
    messages.sort(
      (a, b) {
        return a.createdAt.compareTo(b.createdAt);
      },
    );

    // Store the messages in the local database (using simple mode)
    for (var message in messages) {
      storeMessage(message, conversation, simple: true);
    }

    // Update message read time (to sort conversations properly)
    Get.find<ConversationController>().updateMessageRead(
      conversation.id,
      increment: currentProvider.value?.conversation.id != conversation.id,
      messageSendTime: messages.last.createdAt.millisecondsSinceEpoch,
    );

    // Tell the server about the new read state in case the messages have been received properly
    if (messages.last.senderToken != currentProvider.value?.conversation.token.id) {
      overwriteRead(currentProvider.value!.conversation);
    }
  }
}

/// A message provider that loads messages from a conversation.
class ConversationMessageProvider extends MessageProvider {
  final Conversation conversation;
  ConversationMessageProvider(this.conversation);

  @override
  Future<(List<Message>?, bool)> loadMessagesBefore(int time) async {
    // Load messages from the local database
    final messageQuery = db.select(db.message)
      ..where((tbl) => tbl.conversation.equals(conversation.id.encode()))
      ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(time)));
    final messages = await messageQuery.get();

    // Process the messages in a seperate isolate
    return (await _processMessages(messages), false);
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
  Future<List<Message>> _processMessages(List<MessageData> messages) async {
    // Unpack the messages in an isolate (in a separate thread yk)
    final loadedMessages = await sodiumLib.runIsolated(
      (sodium, keys, pairs) async {
        // Process all messages
        final list = <Message>[];
        for (var data in messages) {
          final message = await decryptFromLocalDatabase(data);

          // Don't render system messages that shouldn't be rendered (this is only for safety, should never actually happen)
          if (message.type == MessageType.system && SystemMessages.messages[message.content]?.render == false) {
            continue;
          }

          // Decrypt system message attachments
          if (message.type == MessageType.system) {
            message.decryptSystemMessageAttachments(keys[0], sodium);
          }

          list.add(message);
        }

        // Return the list to the main isolate
        return list;
      },
      secureKeys: [conversation.key],
    );

    // Init the attachments on all messages and verify signatures
    for (var data in loadedMessages) {
      if (info != null) {
        msg.verifySignature(info);
      }
    }

    return loadedMessages.map((tuple) => tuple.$1).toList();

    // Init the attachments to prepare the messages for rendering
    await Future.wait(unpacked.map((msg) => msg.initAttachments(this)));

    return unpacked;
  }

  /// Decrypt a message from the local database.
  static Future<Message> decryptFromLocalDatabase(MessageData data, {SecureKey? key}) async {
    key ??= databaseKey;

    // Create a new base message
    final message = Message(
      id: data.id,
      type: MessageType.text,
      content: decryptSymmetric(data.content, key),
      answer: "",
      attachments: [],
      senderToken: LPHAddress.from(decryptSymmetric(data.senderToken, key)),
      senderAddress: LPHAddress.from(decryptSymmetric(data.senderToken, key)),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data.createdAt.toInt()),
      edited: data.edited,
      verified: data.verified,
    );

    // Set the type to system in case it is a system message
    if (message.senderToken == MessageController.systemSender) {
      message.type = MessageType.system;
      message.loadContent();
      return message;
    }

    // Load the type, attachments, answer, .. from the content json
    message.loadContent();

    return message;
  }

  @override
  Future<String?> deleteMessage(Message message) async {
    // Check if the message is sent by the user
    final token = Get.find<ConversationController>().conversations[conversation.id]!.token;
    if (message.senderToken != token.id) {
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
