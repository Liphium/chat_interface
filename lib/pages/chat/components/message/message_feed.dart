import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/chat/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/call/call_rectangle.dart';
import 'package:chat_interface/pages/chat/components/message/message_bar.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/call/message_call_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/message_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_interface/connection/messaging.dart' as messaging;

part 'message_actions.dart';
part 'call_start_action.dart';

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

    CallController callController = Get.find();

    if(widget.id == null || widget.id == "0") {
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

        //* Call rectangle
        Obx(() {

          // Check if there is a call in the conversation
          if(callController.conversation.value == controller.selectedConversation.value.id) {
            
            return Expanded(
              flex: callController.hasVideo.value ? 3 : 1,
              child: Obx(() {
            
                // Check if the call is live
                if(callController.livekit.value) {
                  return const CallRectangle();
                }
            
                // Check if the call is not live
                return const Material(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator()
                  )
                );
              }),
            );
          }

          return const SizedBox();
        }),

        Expanded(
          flex: 2,
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
                      
                    switch(message.type) {
                      
                      case "text":
                        return MessageRenderer(message: message, self: self, last: last,
                        sender: self ? Friend("1", statusController.name.value, "", statusController.tag.value) : sender);

                      case "call":
                        return CallMessageRenderer(message: message, self: self, last: last,
                        sender: self ? Friend("1", statusController.name.value, "", statusController.tag.value) : sender);
                    }

                    return null;
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