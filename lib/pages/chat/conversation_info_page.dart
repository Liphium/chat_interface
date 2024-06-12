import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationInfoPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationInfoPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ConversationInfoPage> createState() => _ConversationInfoPageState();
}

class _ConversationInfoPageState extends State<ConversationInfoPage> {
  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text(
          widget.conversation.dmName,
          style: Get.theme.textTheme.labelLarge,
        ),
      ],
      child: Column(
        children: [],
      ),
    );
  }
}
