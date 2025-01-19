import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:get/get.dart';

void setupSetupListeners() {
  //* New status
  connector.listen("setup", (event) {
    final data = event.data["data"]! as String;
    final controller = Get.find<StatusController>();

    if (data == "" || data == "-") {
      controller.status.value = "";
      controller.type.value = statusOnline;
      ConversationService.subscribeToConversations();
      return;
    }

    // Decrypt status with profile key
    controller.fromStatusJson(decryptSymmetric(data, profileKey));

    ConversationService.subscribeToConversations();
  }, afterSetup: true);
}
