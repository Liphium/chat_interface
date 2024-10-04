import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:get/get.dart';

import '../../util/logging_framework.dart';

void setupSetupListeners() {
  //* New status
  connector.listen("setup", (event) {
    final data = event.data["data"]! as String;
    final controller = Get.find<StatusController>();

    if (data == "" || data == "-") {
      controller.status.value = "";
      controller.type.value = statusOnline;
      subscribeToConversations();
      return;
    }

    // Decrypt status with profile key
    controller.fromStatusJson(decryptSymmetric(data, profileKey));

    subscribeToConversations();
  }, afterSetup: true);
}

// status is going to be encrypted in this function
Future<bool> subscribeToConversations({StatusController? controller}) async {
  // Encrypt status with profile key
  controller ??= Get.find<StatusController>();

  // Subscribe to all conversations
  final tokens = <Map<String, dynamic>>[];
  for (var conversation in Get.find<ConversationController>().conversations.values) {
    tokens.add(conversation.token.toMap());
  }

  // Subscribe
  _sub(controller.statusPacket(), controller.sharedContentPacket(), tokens, deletions: true);
  return true;
}

void subscribeToConversation(ConversationToken token, {StatusController? controller, deletions = true}) {
  // Encrypt status with profile key
  controller ??= Get.find<StatusController>();

  // Subscribe to all conversations
  final tokens = <Map<String, dynamic>>[token.toMap()];

  // Subscribe
  _sub(controller.statusPacket(), controller.sharedContentPacket(), tokens, startup: false, deletions: deletions);
}

void _sub(String status, String statusData, List<Map<String, dynamic>> tokens, {bool startup = true, deletions = false}) async {
  connector.sendAction(
      Message("conv_sub", <String, dynamic>{
        "tokens": tokens,
        "status": status,
        "data": statusData,
      }), handler: (event) {
    if (!event.data["success"]) {
      sendLog("ERROR WHILE SUBSCRIBING: ${event.data["message"]}");
      return;
    }
    Get.find<StatusController>().statusLoading.value = false;
    Get.find<ConversationController>().finishedLoading(
      event.data["info"],
      deletions ? (event.data["missing"] ?? []) : [],
      event.data["errors"] ?? [],
      overwriteReads: startup,
    );
  });
}
