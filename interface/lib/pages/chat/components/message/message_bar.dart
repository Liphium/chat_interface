import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
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

    if(widget.conversation.borked) {
      return Material(
        color: Get.theme.colorScheme.onBackground,
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Icon(Icons.person_off, size: 30, color: Theme.of(context).colorScheme.error),
              horizontalSpacing(defaultSpacing),
              Text("friend.removed".tr, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Get.theme.colorScheme.onBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //* Conversation label
            Row(
              children: [
                Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text(widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),

            //* Conversation actions
            Row(
              children: [

                //* Start call
                LoadingIconButton(
                  icon: Icons.call,
                  iconSize: 27,
                  loading: callLoading,
                  onTap: () {
                    final controller = Get.find<SpacesController>();
                    controller.createAndConnect(Get.find<MessageController>().selectedConversation.value.id);
                  },
                ),

                horizontalSpacing(elementSpacing),
                IconButton(
                  iconSize: 27,
                  icon: const Icon(Icons.sticky_note_2),
                  onPressed: () {
                    widget.conversation.delete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}