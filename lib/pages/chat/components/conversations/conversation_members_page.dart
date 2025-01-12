import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:flutter/material.dart';

class ConversationMembersPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationMembersPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ConversationMembersPage> createState() => _ConversationMembersPageState();
}

class _ConversationMembersPageState extends State<ConversationMembersPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
