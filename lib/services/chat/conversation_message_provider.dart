import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/connection/chat/message_listener.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

/// A message provider that loads messages from a conversation.
class ConversationMessageProvider extends MessageProvider {
  final Conversation conversation;
  final String extra;
  ConversationMessageProvider(this.conversation, {this.extra = ""});

  /// Generate a new value key related to this conversation and extra.
  String getKey(String identifier) => "${conversation.id.encode()}-$extra-$identifier";

  @override
  Future<(List<Message>?, bool)> loadMessagesBefore(int time) async {
    // Load messages from the local database
    final messageQuery =
        db.select(db.message)
          ..where(
            (tbl) => tbl.conversation.equals(
              ConversationService.withExtra(conversation.id.encode(), extra),
            ),
          )
          ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(time)))
          ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
          ..limit(10);
    final messages = await messageQuery.get();

    // If there are no messages, check for them on the server
    if (messages.isEmpty) {
      // Check if the user is even connected to the server (to make sure offline retrieval works)
      if (!ConnectionController.connected.value) {
        // Act like the top has been reached
        return (null, false);
      }

      // Load messages from the server
      final json = await postNodeJSON("/conversations/message/list_before", {
        "token": conversation.token.toMap(),
        "data": {"extra": extra, "before": time},
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
      final messages =
          (await MessageListener.unpackMessagesInIsolate(
            conversation,
            json["messages"],
          )).map((msg) => msg.$1).toList();

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
    final messageQuery =
        db.select(db.message)
          ..where(
            (tbl) => tbl.conversation.equals(
              ConversationService.withExtra(conversation.id.encode(), extra),
            ),
          )
          ..where((tbl) => tbl.createdAt.isBiggerThanValue(BigInt.from(time)))
          ..orderBy([(u) => OrderingTerm.asc(u.createdAt)])
          ..limit(10);
    final messages = await messageQuery.get();

    // Process the messages in a seperate isolate
    return (await _processMessages(messages), false);
  }

  @override
  Future<Message?> loadMessageFromServer(String id, {bool init = true}) async {
    // Get the message from the local database
    // Load messages from the local database
    final messageQuery =
        db.select(db.message)
          ..where(
            (tbl) => tbl.conversation.equals(
              ConversationService.withExtra(conversation.id.encode(), extra),
            ),
          )
          ..where((tbl) => tbl.id.equals(id))
          ..limit(1);
    final message = await messageQuery.getSingleOrNull();
    if (message == null) {
      // Check if the user is even connected to the server (to make sure offline retrieval works)
      if (!ConnectionController.connected.value) {
        // Act like the message doesn't exist
        return null;
      }

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
      final (message, _) = decryptFromLocalDatabase(data, databaseKey);

      // Don't render system messages that shouldn't be rendered (this is only for safety, should never actually happen)
      if (message.type == MessageType.system &&
          SystemMessages.messages[message.content]?.render == false) {
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
  ///
  /// Returns message and conversation found in the local database.
  static (Message, String) decryptFromLocalDatabase(
    MessageData data,
    SecureKey key, {
    Sodium? sodium,
  }) {
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
      return (message, data.conversation);
    }

    // Load the type, attachments, answer, .. from the content json
    message.loadContent();

    return (message, data.conversation);
  }

  @override
  Future<String?> deleteMessage(Message message) async {
    // Check if the message is sent by the user
    final token = ConversationController.conversations[conversation.id]!.token;
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
    messages.remove(id);
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
      "data": {"token": timeToken, "data": data, "extra": extra},
    });

    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }
}
