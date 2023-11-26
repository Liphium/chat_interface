import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemMessages {
  static final messages = {
    "group.join": SystemMessage(
      Icons.arrow_forward, 
      handler: (attachments) {
        final selected = Get.find<MessageController>().selectedConversation.value;
        return "";
      },
      translation: (attachments) {
        final selected = Get.find<MessageController>().selectedConversation.value;
        return "hello world lmfao";
      }
    )
  };
}

class SystemMessage {
  final IconData icon;
  final String Function(List<String>) translation;
  final Function(List<String>) handler;

  SystemMessage(this.icon, {required this.handler, required this.translation});
}