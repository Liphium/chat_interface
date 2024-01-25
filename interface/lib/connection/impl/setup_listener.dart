import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

import '../../util/logging_framework.dart';

void setupSetupListeners() {
  //* New status
  connector.listen("setup_st", (event) {
    final data = event.data["data"]! as String;
    final controller = Get.find<StatusController>();

    if (data == "-" || data == "") {
      controller.status.value = "-";
      controller.type.value = statusOnline;
      subscribeToConversations(controller.statusJson(), controller.generateFriendId());
      return;
    }

    // Decrypt status with profile key
    sendLog(data);
    final args = data.split(":");
    final decrypted = decryptSymmetric(args[1], profileKey);
    controller.fromStatusJson(decrypted);

    subscribeToConversations(controller.statusJson(), controller.generateFriendId());
  }, afterSetup: true);

  //* Setup finished
  connector.listen("setup_fin", (event) {
    logger.i("Setup finished");
  });
}

// status is going to be encrypted in this function
Future<bool> subscribeToConversations(String status, String friendId) async {
  // Encrypt status with profile key
  status = generateStatusData(status, friendId);

  // Subscribe to all conversations
  final tokens = <Map<String, dynamic>>[];
  for (var conversation in Get.find<ConversationController>().conversations.values) {
    tokens.add(conversation.token.toMap());
  }

  // Subscribe
  _sub(status, tokens);
  return true;
}

void subscribeToConversation(String status, String friendId, ConversationToken token, {deletions = true}) {
  // Encrypt status with profile key
  status = generateStatusData(status, friendId);

  // Subscribe to all conversations
  final tokens = <Map<String, dynamic>>[token.toMap()];

  // Subscribe
  _sub(status, tokens, startup: false, deletions: deletions);
}

String generateStatusData(String status, String friendId) {
  status = encryptSymmetric(status, profileKey);
  status = "$friendId:$status";

  return status;
}

void _sub(String status, List<Map<String, dynamic>> tokens, {bool startup = true, deletions = false}) async {
  // Get last message received
  final lastMessage = await (db.message.select()
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
        ..limit(1))
      .getSingleOrNull();
  final lastFetch = lastMessage?.createdAt.toInt() ?? 0;

  connector.sendAction(
      Message("conv_sub", <String, dynamic>{
        "tokens": tokens,
        "status": status,
        "date": lastFetch,
      }), handler: (event) {
    if (!event.data["success"]) {
      sendLog("ERROR WHILE SUBSCRIBING: ${event.data["message"]}");
      return;
    }
    Get.find<StatusController>().statusLoading.value = false;
    Get.find<ConversationController>().finishedLoading(event.data["read"], deletions ? (event.data["missing"] ?? []) : [], overwriteReads: startup);
  });
}
