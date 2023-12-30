
import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/conversation_members.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/system_message_renderer.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/pages/spaces/call_rectangle.dart';
import 'package:chat_interface/pages/chat/components/message/message_bar.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/message_space_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/message_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final textNode = FocusNode();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Used in message rendering
    var lastCount = 0;

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
    SettingController settingController = Get.find();

    return Column(
      children: [
        
        //* Header
        Obx(() => MessageBar(conversation: controller.selectedConversation.value)),
    
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                                    
                      //* Message list
                      Expanded(
                        child: SingleChildScrollView(
                          reverse: true,
                          child: SelectableRegion(
                            focusNode: textNode,
                            selectionControls: desktopTextSelectionControls,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: Obx(() {
                                  return ListView.builder(
                                    itemCount: controller.messages.length + 1,
                                    reverse: true,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    itemBuilder: (context, index) {
                                        
                                      if(index == 0) {
                                        return verticalSpacing(defaultSpacing);
                                      }
                                        
                                      final message = controller.messages[index - 1];
                                      if(message.type == MessageType.system) {
                                        return SystemMessageRenderer(message: message, accountId: MessageController.systemSender);
                                      }
                                      final conversationToken = controller.selectedConversation.value.members[message.sender]!;
                                      final sender = friendController.friends[conversationToken.account];
                                      final self = conversationToken.account == statusController.id.value;
                                                
                                      bool last = false;
                                      bool newHeading = false;
                                      if(index != controller.messages.length) {
                                        final lastMessage = controller.messages[index];

                                        // Check if the last message was a day before the current one
                                        if(lastMessage.createdAt.day != message.createdAt.day) {
                                          newHeading = true;
                                        }

                                        if(lastMessage.sender == message.sender && lastCount < 5 && !newHeading) {
                                          last = true;
                                          lastCount++;
                                        } else {
                                          lastCount = 0;
                                        }
                                      }

                                      final Widget renderer;
                                      switch(message.type) {
                                        
                                        case MessageType.text:
                                          renderer = MessageRenderer(message: message, accountId: conversationToken.account, self: self, last: last,
                                          sender: self ? Friend.me() : sender);
                                                
                                        case MessageType.call:
                                          renderer =  SpaceMessageRenderer(message: message, self: self, last: last,
                                          sender: self ? Friend.me() : sender);
                                                          
                                        case MessageType.system:
                                          renderer = SystemMessageRenderer(message: message, accountId: conversationToken.account);
                                      }

                                      final GlobalKey contextMenuKey = GlobalKey();
                                      final hovering = false.obs;
                                      return Column(
                                        children: [
                                          if(newHeading || index == controller.messages.length)
                                            Padding(
                                              padding: const EdgeInsets.only(top: sectionSpacing, bottom: defaultSpacing),
                                              child: Text(formatDay(message.createdAt), style: Get.theme.textTheme.bodyMedium),
                                            ),
                                          MouseRegion(
                                            onEnter: (event) => hovering.value = true,
                                            onExit: (event) => hovering.value = false,
                                            child: Row(
                                              textDirection: self ? TextDirection.rtl : TextDirection.ltr,
                                              children: [
                                                Flexible(
                                                  child: renderer,
                                                ),
                                                Obx(() =>
                                                  SizedBox(
                                                    height: 34,
                                                    child: Visibility(
                                                      visible: hovering.value,
                                                      child: Row(
                                                        children: [
                                                          LoadingIconButton(
                                                            key: contextMenuKey,
                                                            iconSize: 22,
                                                            extra: 4,
                                                            padding: 4,
                                                            onTap: () {
                                                              Get.dialog(MessageOptionsWindow(data: ContextMenuData.fromKey(contextMenuKey), self: self, message: message,));
                                                            }, 
                                                            icon: Icons.more_horiz
                                                          )
                                                        ],
                                                      )
                                                    ),
                                                  )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                                    
                      //* Message input
                      conversation.borked ?
                      const SizedBox.shrink() :
                      const MessageInput()
                    ],
                  ),
                ),
              ),
              Obx(() => 
                Visibility(
                  visible: controller.selectedConversation.value.isGroup && settingController.settings[AppSettings.showGroupMembers]!.value.value,
                  child: Container(
                    color: Get.theme.colorScheme.onBackground,
                    width: 300,
                    child: ConversationMembers(conversation: conversation,),
                  )
                )
              )
            ],
          ),
        ),
      ],
    );
  }
}