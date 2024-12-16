import 'dart:async';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/message_listener.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/messages_page.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
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

  final showSearch = false.obs;
  final hideSidebar = false.obs;
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

  Future<void> selectConversation(Conversation conversation) async {
    currentOpenType.value = OpenTabType.conversation;
    loaded.value = false;
    currentProvider.value = ConversationMessageProvider(conversation);
    if (isMobileMode()) {
      unawaited(Get.to(MessagesPageMobile(provider: currentProvider.value!)));
    }
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      await overwriteRead(conversation);
    }

    // Make sure the thing has some messages in it
    await currentProvider.value!.loadNewMessagesTop(date: DateTime.now().millisecondsSinceEpoch);

    loaded.value = true;
  }

  // Push read state to the server
  Future<void> overwriteRead(Conversation conversation) async {
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
  Future<bool> storeMessage(
    Message message,
    Conversation conversation, {
    bool simple = false,
    (String, String)? part,
  }) async {
    // Ignore certain things in case they are already done or not needed
    if (!simple) {
      // Update message read time for conversations (nessecary for notification count)
      Get.find<ConversationController>().updateMessageRead(
        conversation.id,
        increment: currentProvider.value?.conversation.id != conversation.id,
        messageSendTime: message.createdAt.millisecondsSinceEpoch,
      );

      // Play a notification sound when a new message arrives
      unawaited(RingingManager.playNotificationSound());
    }

    // Add message to message history if it's the selected one
    if (currentProvider.value?.conversation.id == conversation.id) {
      if (message.senderToken != currentProvider.value?.conversation.token.id && !simple) {
        await overwriteRead(currentProvider.value!.conversation);
      }

      // Check if it is a system message and if it should be rendered or not
      if (message.type == MessageType.system) {
        if (SystemMessages.messages[message.content]?.render == true) {
          unawaited(currentProvider.value!.addMessageToBottom(message));
        }
      } else {
        // Store normal type of message
        if (currentProvider.value!.messages.isNotEmpty && currentProvider.value!.messages[0].id != message.id) {
          unawaited(currentProvider.value!.addMessageToBottom(message));
        } else if (currentProvider.value!.messages.isEmpty) {
          unawaited(currentProvider.value!.addMessageToBottom(message));
        }
      }
    }

    // Handle system messages
    if (message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message, currentProvider.value!);

      // Check if message should be stored
      if (SystemMessages.messages[message.content]?.store ?? false) {
        // Store message in local database
        _storeInLocalDatabase(conversation, message, part: part);
      }
    } else {
      // Store message in local database
      _storeInLocalDatabase(conversation, message, part: part);
    }

    // On call message type, ring using the message TODO: Reintroduce the ringtone in Spaces
    /*
    if (message.type == MessageType.call && message.senderAddress != StatusController.ownAddress) {
      final container = SpaceConnectionContainer.fromJson(jsonDecode(message.content));
      RingingManager.startRinging(conversation, container);
    }
    */

    return true;
  }

  /// Store a message in the local database.
  void _storeInLocalDatabase(Conversation conversation, Message message, {(String, String)? part}) {
    db.into(db.message).insertOnConflictUpdate(
          MessageData(
            id: message.id,
            content: part?.$1 ?? encryptSymmetric(message.toContentJson(), databaseKey),
            senderToken: message.senderToken.encode(),
            senderAddress: part?.$2 ?? encryptSymmetric(message.senderAddress.encode(), databaseKey),
            createdAt: BigInt.from(message.createdAt.millisecondsSinceEpoch),
            conversation: conversation.id.encode(),
            edited: message.edited,
            verified: message.verified.value,
          ),
        );
  }

  /// Store all of the messages in the list in the local database.
  ///
  /// This method doesn't play a sound because it's only used for synchronization.
  Future<bool> storeMessages(List<Message> messages, Conversation conversation) async {
    if (messages.isEmpty) {
      return false;
    }

    // Sort all the messages to prevent failing system messages
    messages.sort(
      (a, b) {
        return a.createdAt.compareTo(b.createdAt);
      },
    );

    // Encrypt everything for local database storage
    final copied = Conversation.copyWithoutKey(conversation);
    final parts = await sodiumLib.runIsolated((sodium, keys, pairs) async {
      final list = <(String, String)>[];
      for (var message in messages) {
        list.add((
          encryptSymmetric(message.toContentJson(), keys[0], sodium),
          encryptSymmetric(message.senderAddress.encode(), keys[0], sodium),
        ));
      }

      return list;
    }, secureKeys: [databaseKey]);

    // Store all the messages in the local database
    int index = 0;
    for (var message in messages) {
      await storeMessage(
        message,
        copied,
        simple: true,
        part: parts[index],
      );
      index++;
    }

    // Update message read time (to sort conversations properly)
    Get.find<ConversationController>().updateMessageRead(
      conversation.id,
      increment: currentProvider.value?.conversation.id != conversation.id,
      messageSendTime: messages.last.createdAt.millisecondsSinceEpoch,
    );

    // Tell the server about the new read state in case the messages have been received properly
    if (currentProvider.value != null && currentProvider.value?.conversation.token.id != messages.last.senderToken) {
      await overwriteRead(currentProvider.value!.conversation);
    }

    return true;
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
      ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(time)))
      ..orderBy([(u) => OrderingTerm.desc(u.createdAt)]);
    final messages = await messageQuery.get();

    // If there are no messages on the client, check for them on the server
    if (messages.isEmpty) {
      // Load messages from the server
      final json = await postNodeJSON("/conversations/message/list_before", {
        "token": conversation.token.toMap(),
        "data": time,
      });

      // Check if there was an error
      if (!json["success"]) {
        conversation.error.value = json["error"];
        return (null, true);
      }

      // Check if the top has been reached
      if (json["messages"] == null || json["messages"].isEmpty) {
        return (null, false);
      }
      // Unpack the messages in an isolate
      final messages = await MessageListener.unpackMessagesInIsolate(conversation, json["messages"]);

      // Prepare messages for
      await initAttachmentsForMessages(messages);
      return (messages, false);
    }

    // Process the messages in a seperate isolate
    return (await _processMessages(messages), false);
  }

  @override
  Future<(List<Message>?, bool)> loadMessagesAfter(int time) async {
    // Load messages from the local database
    final messageQuery = db.select(db.message)
      ..where((tbl) => tbl.conversation.equals(conversation.id.encode()))
      ..where((tbl) => tbl.createdAt.isBiggerThanValue(BigInt.from(time)))
      ..orderBy([(u) => OrderingTerm.asc(u.createdAt)]);
    final messages = await messageQuery.get();

    // If there are no messages, check if there are some on the server
    if (messages.isEmpty) {
      // Load the messages from the server
      final json = await postNodeJSON("/conversations/message/list_after", {
        "token": conversation.token.toMap(),
        "data": time,
      });

      // Check if there was an error
      if (!json["success"]) {
        conversation.error.value = json["error"];
        return (null, true);
      }

      // Check if the bottom has been reached
      if (json["messages"] == null || json["messages"].isEmpty) {
        return (null, false);
      }

      // Unpack the messages in an isolate
      final messages = await MessageListener.unpackMessagesInIsolate(conversation, json["messages"]);

      // Prepare messages for
      await initAttachmentsForMessages(messages);
      return (messages, false);
    }

    // Process the messages in a seperate isolate
    return (await _processMessages(messages), false);
  }

  @override
  Future<Message?> loadMessageFromServer(String id, {bool init = true}) async {
    // Get the message from the local database
    // Load messages from the local database
    final messageQuery = db.select(db.message)
      ..where((tbl) => tbl.conversation.equals(conversation.id.encode()))
      ..where((tbl) => tbl.id.equals(id))
      ..limit(1);
    final message = await messageQuery.getSingleOrNull();
    if (message == null) {
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
      final message = await MessageListener.unpackMessageInIsolate(conversation, json["message"]);
      if (init) {
        await message.initAttachments(this);
      }

      return message;
    }

    // Process message as a new list and grab it from the list when finished
    return (await _processMessages([message], init: init))[0];
  }

  /// Process a message payload from the local database.
  /// TODO: Possibly run this in an isolate in the future (needs really advanced code)
  ///
  /// For the future: TODO: Also process the signatures in the isolate by preloading profiles
  Future<List<Message>> _processMessages(List<MessageData> messages, {bool init = true}) async {
    if (messages.isEmpty) {
      return [];
    }

    // Process all messages
    final list = <Message>[];
    for (var data in messages) {
      final message = decryptFromLocalDatabase(data, databaseKey);

      // Don't render system messages that shouldn't be rendered (this is only for safety, should never actually happen)
      if (message.type == MessageType.system && SystemMessages.messages[message.content]?.render == false) {
        continue;
      }

      list.add(message);
    }

    // Init the attachments to prepare the messages for rendering (if desired)
    if (init) {
      await initAttachmentsForMessages(list);
    }

    return list;
  }

  /// Init the attachments for all passed in messages.
  Future<bool> initAttachmentsForMessages(List<Message> messages) async {
    await Future.wait(messages.map((msg) => msg.initAttachments(this)));
    return true;
  }

  /// Decrypt a message from the local database.
  static Message decryptFromLocalDatabase(MessageData data, SecureKey key, {Sodium? sodium}) {
    // Create a new base message
    final message = Message(
      id: data.id,
      type: MessageType.text,
      content: decryptSymmetric(data.content, key, sodium),
      answer: "",
      attachments: [],
      senderToken: LPHAddress.from(data.senderToken),
      senderAddress: LPHAddress.from(decryptSymmetric(data.senderAddress, key, sodium)),
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

    if (!json["success"]) {
      return json["error"];
    }

    return null;
  }

  @override
  Future<bool> deleteMessageFromClient(String id) async {
    messages.removeWhere((element) => element.id == id);
    await db.message.deleteWhere((tbl) => tbl.id.equals(id));
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
