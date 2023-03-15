
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/controller/chat/writing_controller.dart';
import 'package:get/get.dart';

void typingStatus(msg.Event event) {

  WritingController controller = Get.find();

  switch(event.name) {
    case "conv_t":
      controller.add(event.data["id"], event.sender);
      break;

    case "conv_t_s":
      controller.remove(event.data["id"], event.sender);
      break;
  }

}

bool isTyping = false;

void startTyping() {
  if(isTyping) return;
  isTyping = true;

  connector.sendAction(msg.Message("conv_t", <String, dynamic>{
    "id": Get.find<MessageController>().selectedConversation.value.id
  }));
}

void stopTyping() {
  if(!isTyping) return;
  isTyping = false;

  connector.sendAction(msg.Message("conv_t_s", <String, dynamic>{
    "id": Get.find<MessageController>().selectedConversation.value.id
  }));
}