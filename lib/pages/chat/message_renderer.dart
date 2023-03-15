import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/controller/chat/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/vertical_spacing.dart';

class MessageRenderer extends StatefulWidget {

  final Message message;
  final bool self;
  final Friend? sender;

  const MessageRenderer({super.key, required this.message, this.self = false, this.sender});

  @override
  State<MessageRenderer> createState() => _MessageRendererState();
}

class _MessageRendererState extends State<MessageRenderer> {
  @override
  Widget build(BuildContext context) {

    Friend sender = widget.sender ?? Friend(0, "System", "fjc");
    ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () => {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.2, horizontal: defaultSpacing * 2),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.self ? theme.colorScheme.secondaryContainer : theme.colorScheme.primaryContainer,
              child: const Icon(Icons.person),
            ),
            horizontalSpacing(defaultSpacing),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(sender.name),
                    horizontalSpacing(defaultSpacing * 2),
                    Text(widget.message.createdAt.toIso8601String()),
                  ],
                ),
                verticalSpacing(defaultSpacing * 0.1),
                Text(widget.message.content),
              ],
            )
          ],
        ),
      ),
    );
  }
}