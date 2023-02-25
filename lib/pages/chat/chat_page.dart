import 'package:chat_interface/pages/chat/message_feed.dart';
import 'package:chat_interface/pages/chat/sidebar.dart';
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
    return Scaffold(

      body: Row(
        children: [
          const SizedBox(
            width: 350,
            child: Sidebar(),
          ),
          Expanded(
            child: MessageFeed(),
          ),
        ],
      )
    );
  }
}