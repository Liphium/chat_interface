import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar_mobile.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesPageMobile extends StatefulWidget {
  final ConversationMessageProvider provider;

  const MessagesPageMobile({super.key, required this.provider});

  @override
  State<MessagesPageMobile> createState() => _MessagesPageMobileState();
}

class _MessagesPageMobileState extends State<MessagesPageMobile> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return PlatformCallback(
      desktop: () {
        Get.back();
        Get.off(const ChatPageDesktop());
        Get.find<MessageController>().selectConversation(widget.provider.conversation);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.inverseSurface,
        body: Column(
          children: [
            // Render the message bar for mobile
            DevicePadding(
              top: true,
              padding: const EdgeInsets.all(0),
              child: MobileMessageBar(conversation: Get.find<MessageController>().currentProvider.value!.conversation),
            ),

            // Render the actual message feed
            Expanded(
              child: MessageFeed(
                rectInput: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
