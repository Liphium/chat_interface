import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

void setupMessageListener() {

  connector.listen("conv_msg", (event) {

    // Decrypt message
    final controller = Get.find<MessageController>();
    final message = Message.fromJson(event.data["msg"]);
    sendLog("MESSAGE SENT");

    controller.storeMessage(message);
  });

}