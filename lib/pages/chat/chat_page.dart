import 'package:chat_interface/controller/chat/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/util/snackbar.dart';
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

    MessageController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 350,
                child: Sidebar(),
              ),
              Expanded(
                child: Obx(() => MessageFeed(id: controller.selectedConversation.value.id)),
              ),
            ],
          ),

          //* Notifications
          const NotificationRenderer(),
        ],
      )
    );
  }
}
