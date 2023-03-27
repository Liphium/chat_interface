
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/connection/impl/setup/setup_member_listener.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:get/get.dart';

import '../friends/status_listener.dart';
import 'stored_actions_handler.dart';

void setupSetupListeners() {

  //* New device
  connector.listen("setup_device", (event) {
    logger.i("New device: ${event.data["device"]}");
  });

  //* New messages
  connector.listen("setup_msg", (event) {

    // Update messages
    MessageController controller = Get.find();
    controller.newMessages(event.data["messages"]);
  });

  //* New conversations
  connector.listen("setup_conv", (event) {

    // Update conversations
    ConversationController controller = Get.find();
    controller.newConversations(event.data["conversations"]);
  });

  //* New stored actions
  connector.listen("setup_act", (event) {
    event.data["actions"].forEach((action) {
      handleStoredAction(action["action"], action["target"]);
    });
  });

  //* New members
  connector.listen("setup_mem", setupMemberListener);
  connector.listen("setup_st", setupStatusListener);

  //* Setup finished
  connector.listen("setup_fin", (event) {
    logger.i("Setup finished");

    // Update status
    connector.sendAction(msg.Message("acc_on", <String, dynamic>{}));
  });
}