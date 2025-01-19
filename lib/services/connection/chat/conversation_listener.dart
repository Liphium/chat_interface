import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

class ConversationListener {
  static void setupListeners() {
    // Handle late subscriptions from remote servers
    connector.listen("conv_sub:late", (event) {
      sendLog("received late from ${event.data["server"]}");
      final server = event.data["server"];
      if (event.data["error"]) {
        Get.find<ConversationController>().finishedLoading(server, {}, [], true);
      } else {
        Get.find<ConversationController>().finishedLoading(
          server,
          event.data["info"],
          event.data["missing"],
          false,
        );
      }
    });
  }
}
