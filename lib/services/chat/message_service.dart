import 'dart:async';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/controller/spaces/ringing_manager.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';

class MessageService {
  /// Store all of the messages in the list in the local database and cache.
  /// The string next to the message in the list is its extra id.
  ///
  /// This method doesn't play a sound because it's only used for synchronization.
  static Future<bool> storeMessages(List<(Message, String)> messages, Conversation conversation) async {
    if (messages.isEmpty) {
      return false;
    }

    // Sort all the messages to prevent failing system messages
    messages.sort((a, b) {
      return a.$1.createdAt.compareTo(b.$1.createdAt);
    });

    // Encrypt everything for local database storage
    final parts = await sodiumLib.runIsolated((sodium, keys, pairs) async {
      final list = <(String, String)>[];
      for (var (message, _) in messages) {
        list.add((
          dbEncrypted(message.toContentJson(), sodium, keys[0]),
          dbEncrypted(message.senderAddress.encode(), sodium, keys[0]),
        ));
      }

      return list;
    }, secureKeys: [databaseKey]);

    // Store all the messages in the local database
    int index = 0;
    for (var (message, extra) in messages) {
      await storeMessage(message, conversation, extra: extra, simple: true, part: parts[index]);
      index++;
    }

    // Update last message in the conversation
    ConversationService.updateLastMessage(conversation, messages.last.$1.createdAt.millisecondsSinceEpoch);

    return true;
  }

  /// Store a message in the local database and in the cache (if the conversation is selected).
  ///
  /// Also handles system messages.
  /// Set [simple] to [true] in case you want to avoid any extra stuff other than adding to cache and database.
  static Future<bool> storeMessage(
    Message message,
    Conversation conversation, {
    String extra = "",
    bool simple = false,
    (String, String)? part,
  }) async {
    // Get the current provider
    final provider = SidebarController.getCurrentProvider();

    if (!simple) {
      // Update message read time for conversations (nessecary for notification count)
      ConversationService.updateLastMessage(conversation, message.createdAt.millisecondsSinceEpoch);

      // Play a notification sound when a new message arrives
      unawaited(RingingManager.playNotificationSound());
    }

    // Handle system messages
    if (message.type == MessageType.system) {
      if ((provider?.conversation.id ?? "hi") == conversation.id && extra == (provider?.extra ?? "-")) {
        SystemMessages.messages[message.content]?.handle(message, provider!);
      } else {
        SystemMessages.messages[message.content]?.handle(
          message,
          ConversationMessageProvider(conversation, extra: extra),
        );
      }

      // Check if message should be stored
      if (SystemMessages.messages[message.content]?.store ?? false) {
        // Store message in local database
        _storeInLocalDatabase(conversation, message, extra: extra, part: part);
      }
    } else {
      // Store message in local database
      _storeInLocalDatabase(conversation, message, extra: extra, part: part);
    }

    // On call message type, ring using the message TODO: Reintroduce the ringtone in Spaces
    /*
    if (message.type == MessageType.call && message.senderAddress != StatusController.ownAddress) {
      final container = SpaceConnectionContainer.fromJson(jsonDecode(message.content));
      RingingManager.startRinging(conversation, container);
    }
    */

    // Add to the cache
    return MessageController.addMessage(message, conversation, extra: extra, part: part, simple: simple);
  }

  /// Store a message in the database.
  ///
  /// The part tuple is provided by [storeMessages] to not encrypt the data twice.
  static void _storeInLocalDatabase(
    Conversation conversation,
    Message message, {
    required String extra,
    (String, String)? part,
  }) {
    db
        .into(db.message)
        .insertOnConflictUpdate(
          MessageData(
            id: message.id,
            content: part?.$1 ?? dbEncrypted(message.toContentJson()),
            senderToken: message.senderToken.encode(),
            senderAddress: part?.$2 ?? dbEncrypted(message.senderAddress.encode()),
            createdAt: BigInt.from(message.createdAt.millisecondsSinceEpoch),
            conversation: ConversationService.withExtra(conversation.id.encode(), extra),
            edited: message.edited,
            verified: message.verified.value,
          ),
        );
  }

  /// Split a conversation id into the id of the conversation and the extra identifier
  static (String, String) intoIdAndExtra(String convId) {
    final args = convId.split("_");
    return (args[0], args.length == 1 ? "" : args[1]);
  }
}
