import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/current/status_controller.dart';

class MessageBar extends StatelessWidget {

  final Conversation conversation;

  const MessageBar({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {

    StatusController statusController = Get.find();
    FriendController friendController = Get.find();

    return Material(
      color: Theme.of(context).colorScheme.tertiaryContainer.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //* Conversation label
            Row(
              children: [
                Icon(conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.secondary),
                horizontalSpacing(defaultSpacing),
                Text(conversation.getName(statusController, friendController), style: Theme.of(context).textTheme.titleMedium),
              ],
            ),

            //* Conversation actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {},
                ),
                horizontalSpacing(defaultSpacing * 0.1),
                IconButton(
                  icon: const Icon(Icons.sticky_note_2),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}