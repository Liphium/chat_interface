import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageBar extends StatefulWidget {

  final Conversation conversation;

  const MessageBar({super.key, required this.conversation});

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {

  final callLoading = false.obs;

  @override
  Widget build(BuildContext context) {

    StatusController statusController = Get.find();
    FriendController friendController = Get.find();
    ThemeData theme = Theme.of(context);

    widget.conversation.refreshName(statusController, friendController);

    return Material(
      color: theme.colorScheme.onBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //* Conversation label
            Row(
              children: [
                Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.secondary),
                horizontalSpacing(defaultSpacing),
                Text(widget.conversation.decrypted.value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),

            //* Conversation actions
            Row(
              children: [

                //* Start call
                LoadingIconButton(
                  icon: Icons.call,
                  loading: callLoading,
                  onTap: () => startCall(callLoading, widget.conversation.id),
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