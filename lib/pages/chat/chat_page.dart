import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/components/townsquare/townsquare_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final TownsquareController tsController = Get.find();
    final MessageController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Row(
        children: [
          const SizedBox(
            width: 350,
            child: Sidebar(),
          ),
          Expanded(
            child: Obx(() {
              if (tsController.inView.value) {
                return const TownsquareFeed();
              }
              return MessageFeed(conversation: controller.selectedConversation.value);
            }),
          ),
        ],
      ),
    );
  }
}
