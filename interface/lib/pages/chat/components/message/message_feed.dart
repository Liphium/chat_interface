
import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/spaces/call_rectangle.dart';
import 'package:chat_interface/pages/chat/components/message/message_bar.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/message_space_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/message_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

part 'message_actions.dart';

class MessageFeed extends StatefulWidget {

  final String? id;

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

    return Obx(() {
      if(widget.id == null || widget.id == "0") {

        if(Get.find<SpacesController>().inSpace.value) {
          return const CallRectangle();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('app.title'.tr, style: Theme.of(context).textTheme.headlineMedium),
            verticalSpacing(sectionSpacing),
            Text('app.welcome'.tr, style: Theme.of(context).textTheme.bodyLarge),
            verticalSpacing(elementSpacing),
            Text('app.build'.trParams({"build":"Alpha"}), style: Theme.of(context).textTheme.bodyLarge),
          ],
        );
      }

      final conversation = Get.find<ConversationController>().conversations[widget.id]!;
      MessageController controller = Get.find();
      FriendController friendController = Get.find();
      StatusController statusController = Get.find();

      return Column(
        children: [
          
          //* Header
          Obx(() => MessageBar(conversation: controller.selectedConversation.value)),

          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
            
                  //* Message list
                  Obx(() {
                    sendLog("update");
                    final messages = controller.messages;
                    return ListView.builder(
                      itemCount: messages.length + 1,
                      reverse: true,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemBuilder: (context, index) {

                        if(index == 0) {
                          return verticalSpacing(defaultSpacing);
                        }
                          
                        final message = controller.messages[index - 1];
                        final conversationToken = controller.selectedConversation.value.members[message.sender]!;
                        final sender = friendController.friends[conversationToken.account];
                        final self = conversationToken.account == statusController.id.value;
            
                        bool last = false;
                        if(index != controller.messages.length) {
                          final lastMessage = controller.messages[index];
                          last = lastMessage.sender == message.sender && lastMessage.type == MessageType.text;
                        }
                          
                        switch(message.type) {
                          
                          case MessageType.text:
                            return MessageRenderer(message: message, self: self, last: last,
                            sender: self ? Friend.me() : sender);
            
                          case MessageType.call:
                            return SpaceMessageRenderer(message: message, self: self, last: last,
                            sender: self ? Friend.me() : sender);
                        }
                      },
                    );
              }),
            
                  //* Message input
                  conversation.borked ?
                  const SizedBox.shrink() :
                  const MessageInput()
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}