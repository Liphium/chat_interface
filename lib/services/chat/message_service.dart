import 'dart:async';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';

class MessageService {
  /// Store all of the messages in the list in the local database and cache.
  ///
  /// This method doesn't play a sound because it's only used for synchronization.
  static Future<bool> storeMessages(List<Message> messages, Conversation conversation) async {
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
          dbEncrypted(message.toContentJson(), sodium, keys[0]),
          dbEncrypted(message.senderAddress.encode(), sodium, keys[0]),
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
    ConversationService.updateLastMessage(
      conversation.id,
      increment: MessageController.currentProvider.value?.conversation.id != conversation.id,
      messageSendTime: messages.last.createdAt.millisecondsSinceEpoch,
    );

    // Tell the server about the new read state in case the messages have been received properly
    if (MessageController.currentProvider.value != null &&
        MessageController.currentProvider.value?.conversation.token.id != messages.last.senderToken) {
      await ConversationService.overwriteRead(MessageController.currentProvider.value!.conversation);
    }

    return true;
  }

  /// Store a message in the local database and in the cache (if the conversation is selected).
  ///
  /// Also handles system messages.
  static Future<bool> storeMessage(
    Message message,
    Conversation conversation, {
    bool simple = false,
    (String, String)? part,
  }) async {
    // Handle system messages
    if (message.type == MessageType.system) {
      if (MessageController.currentProvider.value?.conversation.id == conversation.id) {
        SystemMessages.messages[message.content]?.handle(message, MessageController.currentProvider.value!);
      } else {
        SystemMessages.messages[message.content]?.handle(message, ConversationMessageProvider(conversation));
      }

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

    // Add to the cache
    return MessageController.addMessage(message, conversation, part: part, simple: simple);
  }

  /// Store a message in the database.
  ///
  /// The part tuple is provided by [storeMessages] to not encrypt the data twice.
  static void _storeInLocalDatabase(Conversation conversation, Message message, {(String, String)? part}) {
    db.into(db.message).insertOnConflictUpdate(
          MessageData(
            id: message.id,
            content: part?.$1 ?? dbEncrypted(message.toContentJson()),
            senderToken: message.senderToken.encode(),
            senderAddress: part?.$2 ?? dbEncrypted(message.senderAddress.encode()),
            createdAt: BigInt.from(message.createdAt.millisecondsSinceEpoch),
            conversation: conversation.id.encode(),
            edited: message.edited,
            verified: message.verified.value,
          ),
        );
  }
}
