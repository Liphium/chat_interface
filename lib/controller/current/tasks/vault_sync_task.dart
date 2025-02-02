import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/library/library_manager.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'vault_actions.dart';

class VaultSyncTask extends SynchronizationTask {
  VaultSyncTask() : super("loading.vault", const Duration(seconds: 30));

  @override
  Future<String?> init() async {
    // Load conversations from the database
    final conversationController = Get.find<ConversationController>();
    final conversations = await (db.select(db.conversation)..orderBy([(u) => OrderingTerm.asc(u.updatedAt)])).get();
    for (var conversation in conversations) {
      await conversationController.add(Conversation.fromData(conversation));
    }
    return null;
  }

  @override
  Future<String?> refresh() async {
    // Refresh the regular vault (conversations and stuff)
    var error = await refreshVault();
    if (error != null) {
      return error;
    }

    // Refresh the library (gifs, saved images, etc.)
    error = await LibraryManager.refreshEntries();
    return error;
  }

  @override
  void onRestart() {}
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

  String decryptedPayload([SecureKey? key, Sodium? sodium]) => decryptSymmetric(payload, key ?? vaultKey, sodium);
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
    var ids = <LPHAddress>[];
    for (var unparsedEntry in json["entries"]) {
      final entry = VaultEntry.fromJson(unparsedEntry);
      final decrypted = decryptSymmetric(entry.payload, keys[0], sodium);
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
      await controller.addFromVault(conversation);
    }
  }

  // Delete all old conversations from the database
  final stringIds = ids.map((id) => id.encode());
  await db.conversation.deleteWhere((tbl) => tbl.id.isNotIn(stringIds));
  await db.member.deleteWhere((tbl) => tbl.conversationId.isNotIn(stringIds));

  return null;
}
