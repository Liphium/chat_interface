
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:get/get.dart';

void setupSetupListeners() {

  // Welcome
  connector.listen("setup_wel", (event) {
    logger.i("Welcome, ${event.data["name"]}#${event.data["tag"]}");
  });

  // New device
  connector.listen("setup_device", (event) {
    logger.i("New device: ${event.data["device"]}");
  });

  // New messages
  connector.listen("setup_messages", (event) {

    // Update messages
    MessageController controller = Get.find();
    controller.newMessages(event.data["messages"]);
  });

  // New conversations
  connector.listen("setup_conversations", (event) {

    // Update conversations
    ConversationController controller = Get.find();
    controller.newConversations(event.data["conversations"]);
  });
}