import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';

void setupSetupListeners() {
  //* New status
  connector.listen("setup", (event) {
    final data = event.data["data"]! as String;

    if (data == "" || data == "-") {
      StatusController.status.value = "";
      StatusController.type.value = statusOnline;
      ConversationService.subscribeToConversations();
      return;
    }

    // Decrypt status with profile key
    StatusController.fromStatusJson(decryptSymmetric(data, profileKey));

    ConversationService.subscribeToConversations();
  }, afterSetup: true);
}
