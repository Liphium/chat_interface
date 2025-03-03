import 'dart:convert';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class ConversationVaultTarget extends VaultTarget {
  ConversationVaultTarget() : super(Constants.vaultConversationTag);

  @override
  Future<int> getLatestVersion() async {
    // Get the latest conersation entry version
    final max = db.conversation.vaultVersion.max();
    final query = db.selectOnly(db.conversation)..addColumns([max]);
    final maxValue = await query.map((row) => row.read(max)).getSingleOrNull();

    // Return zero in case nothing has been stored yet
    return maxValue?.toInt() ?? 0;
  }

  @override
  Future<void> init() async {
    final conversationController = Get.find<ConversationController>();
    final conversations = await (db.select(db.conversation)..orderBy([(u) => OrderingTerm.asc(u.updatedAt)])).get();
    for (var conversation in conversations) {
      await conversationController.add(Conversation.fromData(conversation));
    }
  }

  @override
  Future<void> processEntries(List<String> deleted, List<VaultEntry> newEntries) async {
    // Add all the new conversations to the vault
    final messageController = Get.find<MessageController>();
    final controller = Get.find<ConversationController>();
    for (var entry in newEntries) {
      final conv = Conversation.fromJson(jsonDecode(entry.payload), entry.id);
      await controller.addFromVault(conv);
    }

    // Delete everything that's been deleted from the vault on the server
    controller.conversations.removeWhere((id, conv) {
      if (deleted.contains(conv.vaultId)) {
        ConversationService.delete(id, vaultId: conv.vaultId, deleteLocal: false);
        controller.order.remove(id);
        messageController.unselectConversation(id: id);
        return true;
      }
      return false;
    });
  }
}
