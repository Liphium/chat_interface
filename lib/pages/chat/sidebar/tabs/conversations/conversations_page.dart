import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/impl/messages/typing_listener.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:chat_interface/controller/chat/writing_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/theme/ui/conversation_add/conversation_add_window.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:livekit_client/livekit_client.dart';

import '../../../../../controller/chat/friend_controller.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {

  final GlobalKey _addKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    MessageController messageController = Get.find();
    StatusController statusController = Get.find();
    FriendController friendController = Get.find();
    ConversationController controller = Get.find();
    WritingController writingController = Get.find();

    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
          child: SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInput(theme),
                horizontalSpacing(defaultSpacing),
                SizedBox(
                  key: _addKey,
                  width: 48,
                  height: 48,
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.colorScheme.secondaryContainer,
                    elevation: 2.0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        final RenderBox box = _addKey.currentContext?.findRenderObject() as RenderBox;

                        //* Open conversation add window
                        Get.dialog(ConversationAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Icon(Icons.add, color: theme.colorScheme.primary),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),

            //* Conversation list
            child: Obx(() => controller.conversations.isNotEmpty && controller.newConvs == 0 ? 
            ListView.builder(
              itemCount: controller.conversations.length,
              addRepaintBoundaries: true,
              padding: const EdgeInsets.only(top: defaultSpacing),
              itemBuilder: (context, index) {
                Conversation conversation = controller.conversations.values.elementAt(index);
                conversation.refreshName(statusController, friendController);

                final hover = false.obs;
                
                //* Conversation item
                return Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                  child: Obx(() => 
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    color: messageController.selectedConversation.value == conversation ? theme.colorScheme.secondaryContainer.withAlpha(100) : Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      hoverColor: theme.colorScheme.secondaryContainer.withAlpha(100),
                      splashColor: theme.hoverColor,
                      onHover: (value) {
                        hover.value = value;
                      },

                      //* When conversation is tapped (open conversation)
                      onTap: () {
                        if(messageController.selectedConversation.value == conversation) return;
                        stopTyping();
                        messageController.selectConversation(conversation);
                      },

                      //* Conversation item content
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            //* Conversation info
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(conversation.isGroup ? Icons.group : Icons.person, size: 35, color: theme.colorScheme.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Conversation title
                                        Text(conversation.decrypted.value, style: theme.textTheme.titleMedium),
                                                              
                                        // Conversation description
                                        Obx(() =>
                                          Text(
                                                              
                                            //* Conversation status message
                                            conversation.isGroup ? "chat.members".trParams(<String, String>{
                                              'count': conversation.members.length.toString()
                                            }) : 
                                            conversation.status(statusController, friendController),
                                                              
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Obx(() =>
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Visibility(
                                  visible: hover.value,

                                  //* Writing indicator (only visible on not hover)
                                  replacement: Obx(() =>
                                    (writingController.writing[conversation.id] ?? []).isNotEmpty ?
                                    const Padding(
                                      padding: EdgeInsets.all(defaultSpacing * 1.2),
                                      child: CircularProgressIndicator(strokeWidth: 3.0,)
                                    ) : const SizedBox(),
                                  ),

                                  //* Call button (only visible on hover)
                                  child: IconButton(
                                    icon: Icon(Icons.call, color: theme.colorScheme.primary),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                    ),
                  )),
                );
              },
            ) :
            controller.loaded.value ?

            //* Empty conversation list
            Center(child: Text('conversations.empty'.tr, style: theme.textTheme.titleMedium)) :

            //* Loading indicator
            const Center(child: CircularProgressIndicator())),
          ),
        ),
      ],
    );
  }
}

Widget buildInput(ThemeData theme) {
  return Expanded(
    child: Material(
      borderRadius: BorderRadius.circular(10),
      color: theme.colorScheme.secondaryContainer,
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            hintText: 'conversations.placeholder'.tr,
          ),
        ),
      ),
    ),
  );
}