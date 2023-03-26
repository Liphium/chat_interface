import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/message_bar.dart';
import 'package:chat_interface/pages/chat/message_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_interface/connection/messaging.dart' as messaging;

import '../../controller/chat/message_controller.dart';

part 'message_actions.dart';

class MessageFeed extends StatefulWidget {

  final int? id;

  const MessageFeed({super.key, this.id});

  @override
  State<MessageFeed> createState() => _MessageFeedState();
}

class _MessageFeedState extends State<MessageFeed> {

  final TextEditingController _message = TextEditingController();
  final loading = false.obs;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.id == null || widget.id == 0) {
      return Center(
        child: Text('chat.welcome.1.0.0'.tr, style: Theme.of(context).textTheme.titleLarge),
      );
    }

    MessageController controller = Get.find();
    FriendController friendController = Get.find();
    StatusController statusController = Get.find();

    return Column(
      children: [
        
        //* Header
        Obx(() => MessageBar(conversation: controller.selectedConversation.value)),

        Expanded(
          child: Stack(
            children: [

              //* Message list
              Obx(() => 
                ListView.builder(
                  itemCount: controller.messages.length + 1,
                  reverse: true,
                  itemBuilder: (context, index) {
                      
                    if(index == 0) {
                      return verticalSpacing(defaultSpacing * 12);
                    }
                      
                    final message = controller.messages[index - 1];
                    final sender = friendController.friends[message.sender];
                    final self = statusController.id.value == message.sender;

                    bool last = false;
                    if(index != controller.messages.length) {
                      final lastMessage = controller.messages[index];
                      last = lastMessage.sender == message.sender;
                    }
                      
                    return MessageRenderer(message: message, self: self, last: last,
                    sender: self ? Friend(1, statusController.name.value, "", statusController.tag.value) : sender);
                  },
                ),
              ),

              //* Message input
              const MessageInput()
            ],
          ),
        ),
      ],
    );
  }
}