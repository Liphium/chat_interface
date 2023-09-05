import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscribeSetup extends Setup {

  SubscribeSetup() : super("loading.subscribe", false);

  @override
  Future<Widget?> load() async {
    
    // Subscribe to all conversations
    final tokens = <Map<String, dynamic>>[];
    for(var conversation in Get.find<ConversationController>().conversations.values) {
      tokens.add(conversation.token.toMap());
    }

    // Subscribe
    connector.sendAction(Message("conv_sub", <String, dynamic>{
      "tokens": tokens,
      "status": "hello world",
    }), handler: (event) {
      if(!event.data["success"]) {
        sendLog("ERROR WHILE SUBSCRIBING: ${event.data["message"]}");
        return;
      }
    });

    return null;
  }

}