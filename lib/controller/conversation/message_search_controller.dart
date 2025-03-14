import 'dart:async';

import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart';
import 'package:signals/signals_flutter.dart';

class MessageSearchController {
  static final filters = listSignal(<MessageFilter>[]);
  static final results = listSignal(<Message>[]);
  static FocusNode? currentFocus;

  // Data for the message search algorithm
  static bool _finished = false;
  static bool _restart = false;
  static int _lastTime = 0;
  static Timer? _searchTimer;
  static int neededMessages = 10;

  static void search({bool increment = false}) {
    _searchTimer?.cancel();
    if (increment) {
      if (_finished) {
        return;
      }
      neededMessages += 10;
      _restart = false;
    } else {
      neededMessages = 10;
      _restart = true;
    }
    bool working = false;
    _searchTimer = Timer.periodic(
      Duration(milliseconds: 50),
      (timer) async {
        final wasRestart = _restart;
        if (_restart) {
          _restart = false;
          _lastTime = DateTime.now().millisecondsSinceEpoch;
        }
        if (working) {
          return;
        }
        working = true;

        // Check if there is a conversation filter
        final convFilter = filters.firstWhereOrNull((f) => f is ConversationFilter) as ConversationFilter?;

        // Grab all the messages from the list using the offset
        // Make sure to only search in the current conversation in case there is a conversation filter
        final SimpleSelectStatement<$MessageTable, MessageData> messageQuery;
        if (convFilter != null) {
          messageQuery = db.select(db.message)
            ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(_lastTime)))
            ..where((tbl) => tbl.conversation.equals(convFilter.conversationId))
            ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
            ..limit(100);
        } else {
          messageQuery = db.select(db.message)
            ..where((tbl) => tbl.createdAt.isSmallerThanValue(BigInt.from(_lastTime)))
            ..orderBy([(u) => OrderingTerm.desc(u.createdAt)])
            ..limit(100);
        }

        // Make sure to only search in the current conversation in case there is a conversation filter
        if (convFilter != null) {}
        final messages = await messageQuery.get();

        // If there are no messages, cancel the timer
        if (messages.isEmpty) {
          timer.cancel();
          return;
        }

        // Set the last message time to make sure messages aren't loaded twice
        _lastTime = messages.last.createdAt.toInt();

        // Check all the filters for the current messages (maybe put in an isolate in the future?)
        final found = <Message>[];
        for (var message in messages) {
          final (processed, conversation) = ConversationMessageProvider.decryptFromLocalDatabase(message, databaseKey);

          // Maybe remove this limitation in the future?
          if (processed.type != MessageType.text) {
            continue;
          }

          bool fail = false;
          for (var filter in filters) {
            if (!filter.matches(processed, conversation: conversation)) {
              fail = true;
              break;
            }
          }

          if (!fail) {
            found.add(processed);
          }
        }

        // Initialize all the attachments on the messages
        for (var msg in found) {
          await msg.initAttachments(null);
        }

        // Add all found results to the list
        if (wasRestart) {
          results.value = found;
        } else {
          results.addAll(found);

          // Check if the algorithm should be stopped for now
          if (results.length >= neededMessages) {
            timer.cancel();
          }
        }

        // Check if fetching can be stopped
        if (messages.length < 100) {
          _finished = true;
          timer.cancel();
        }

        working = false;
      },
    );
  }
}

/// Abstract class for all filters related to messages
abstract class MessageFilter {
  /// This function is called for every message in the database.
  ///
  /// If it returns true, the message will be loaded as part of the search results.
  bool matches(Message message, {String? conversation});
}

/// Filter for all messages in a conversation
class ConversationFilter extends MessageFilter {
  final String conversationId;

  ConversationFilter(this.conversationId);

  @override
  bool matches(Message message, {String? conversation}) {
    if (conversation == null) {
      return false;
    }

    return conversationId == conversation;
  }
}

/// Filter that checks if a certain piece of content is in a message
class ContentFilter extends MessageFilter {
  final String content;

  ContentFilter(this.content);

  @override
  bool matches(Message message, {String? conversation}) {
    // Split the search query into words
    final searchWords = content.toLowerCase().split(RegExp(r'\s+'));

    // Check if all words in the search query are found in the content
    final contentWords = message.content.toLowerCase().split(RegExp(r'\s+'));
    if (searchWords.every((word) => contentWords.any((contentWord) => contentWord.contains(word)))) {
      return true;
    }

    // Check if all words in the search query are found in any attachment
    for (var attachment in message.attachments) {
      final attachmentWords = attachment.toLowerCase().split(RegExp(r'\s+'));
      if (searchWords.every((word) => attachmentWords.any((attachmentWord) => attachmentWord.contains(word)))) {
        return true;
      }
    }

    // No matches found
    return false;
  }
}
