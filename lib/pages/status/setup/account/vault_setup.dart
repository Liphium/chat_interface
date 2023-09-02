import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_finish_setup.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'vault_actions.dart';

class VaultSetup extends Setup {

  VaultSetup() : super("loading.vault", false);

  @override
  Future<Widget?> load() async {
    
    // Refresh the vault
    await refreshVault();

    // Load conversations from the database
    final conversationController = Get.find<ConversationController>();
    final conversations = await (db.select(db.conversation)).get();
    for(var conversation in conversations) {
      await conversationController.add(Conversation.fromData(conversation));
    }

    conversationController.finishedLoading();

    return null;
  }

}

class VaultEntry {
  final String id;
  final String tag;
  final String account;
  final String payload;
  final int updatedAt;

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
  await startFetch();

  // Load conversations
  final json = await postAuthorizedJSON("/account/vault/list", <String, dynamic>{
    "after": lastFetchTime.millisecondsSinceEpoch, // Unix
    "tag": Constants.conversationTag
  });
  if(!json["success"]) {
    return json["error"];
  }

  for(var unparsedEntry in json["entries"]) {
    final entry = VaultEntry.fromJson(unparsedEntry);
    sendLog(entry);
  }

  await finishFetch();
  return null;
}

