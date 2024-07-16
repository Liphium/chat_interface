import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'vault_actions.dart';

class VaultSetup extends Setup {
  VaultSetup() : super("loading.vault", false);

  @override
  Future<Widget?> load() async {
    // Load conversations from the database
    final conversationController = Get.find<ConversationController>();
    final conversations = await (db.select(db.conversation)..orderBy([(u) => OrderingTerm.asc(u.updatedAt)])).get();
    for (var conversation in conversations) {
      await conversationController.add(Conversation.fromData(conversation));
    }

    // Refresh the vault
    await refreshVault();

    return null;
  }
}

class VaultEntry {
  final String id;
  final String tag;
  final String account;
  final String payload;
  final int updatedAt;
  bool error = false;

  VaultEntry(this.id, this.tag, this.account, this.payload, this.updatedAt);
  VaultEntry.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        tag = json["tag"],
        account = json["account"],
        payload = json["payload"],
        updatedAt = json["updated_at"];
}

// Returns an error string (null if successful)
Future<String?> refreshVault() async {
  // Load conversations
  final json = await postAuthorizedJSON("/account/vault/list", <String, dynamic>{
    "after": 0, // Unix
    "tag": Constants.vaultConversationTag,
  });
  if (!json["success"]) {
    return json["error"];
  }

  sendLog("loading..");
  sendLog(json["entries"].length);

  // Run decryption and decoding in a separate isolate
  final (conversations, ids) = await sodiumLib.runIsolated((sodium, keys, pairs) {
    var list = <Conversation>[];
    var ids = <String>[];
    for (var unparsedEntry in json["entries"]) {
      final entry = VaultEntry.fromJson(unparsedEntry);
      final decrypted = decryptSymmetric(entry.payload, keys[0]);
      final decoded = jsonDecode(decrypted);
      final conv = Conversation.fromJson(decoded, entry.id);
      list.add(conv);
      ids.add(conv.id);
    }

    return (list, ids);
  }, secureKeys: [vaultKey]);

  // Delete all old conversations in the cache
  final messageController = Get.find<MessageController>();
  final controller = Get.find<ConversationController>();
  controller.conversations.removeWhere((id, conv) {
    final remove = !ids.contains(id);
    if (remove) {
      controller.order.remove(id);
      messageController.unselectConversation(id: id);
    }
    return remove;
  });

  // Add all new conversations
  for (var conversation in conversations) {
    if (controller.conversations[conversation.id] == null) {
      controller.addFromVault(conversation);
    }
  }

  // Delete all old conversations from the database
  db.conversation.deleteWhere((tbl) => tbl.id.isNotIn(ids));
  db.member.deleteWhere((tbl) => tbl.conversationId.isNotIn(ids));

  return null;
}
