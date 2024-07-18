import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationPage({super.key, required this.conversation});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return PlatformCallback(
      desktop: () {
        Get.back();
        Get.off(const ChatPageDesktop());
        Get.find<MessageController>().selectConversation(widget.conversation);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.inverseSurface,
        body: SelectionArea(
          child: MessageFeed(conversation: widget.conversation),
        ),
      ),
    );
  }
}
