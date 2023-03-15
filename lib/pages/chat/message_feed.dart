import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/message_bar.dart';
import 'package:chat_interface/pages/chat/message_renderer.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      return verticalSpacing(defaultSpacing * 9);
                    }
                      
                    final message = controller.messages[index - 1];
                    final sender = friendController.friends[message.sender];
                    final self = statusController.id.value == message.sender;
                      
                    return MessageRenderer(message: message, self: self, sender: self ? Friend(1, statusController.name.value, statusController.tag.value) : sender);
                  },
                ),
              ),

              //* Message input
              Padding(
                padding: const EdgeInsets.all(defaultSpacing * 2),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    elevation: 10,
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultSpacing,
                        vertical: defaultSpacing * 0.1,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => {},
                            icon: const Icon(Icons.add),
                            tooltip: "soon",
                          ),
                          horizontalSpacing(defaultSpacing),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'chat.message'.tr,
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1000),
                              ],
                              controller: _message,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          horizontalSpacing(defaultSpacing),
                          LoadingIconButton(
                            onTap: () => sendMessage(loading, controller.selectedConversation.value.id, _message.text, () {
                              _message.clear();
                              loading.value = false;
                            }),
                            icon: Icons.send,
                            loading: loading,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}