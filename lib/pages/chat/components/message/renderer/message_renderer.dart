
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageRenderer extends StatefulWidget {

  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const MessageRenderer({super.key, required this.message, this.self = false, this.last = false, this.sender});

  @override
  State<MessageRenderer> createState() => _MessageRendererState();
}

class _MessageRendererState extends State<MessageRenderer> {
  @override
  Widget build(BuildContext context) {

    Friend sender = widget.sender ?? Friend.system();
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: !widget.last ? defaultSpacing : 0),
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        splashColor: theme.hoverColor,
        onTap: () => {},
        child: Padding(
          padding: const EdgeInsets.only(
            top: defaultSpacing * 0.4,
            bottom: defaultSpacing * 0.4,
            right: defaultSpacing * 2,
            left: defaultSpacing * 2
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //* Avatar
              Visibility(
                visible: !widget.last,
                replacement: const SizedBox(width: 40), //* Show timestamp instead
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircleAvatar(
                    backgroundColor: widget.self ? theme.colorScheme.secondaryContainer : theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.person),
                  ),
                ),
              ),
              horizontalSpacing(defaultSpacing),

              //* Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    //* Message info
                    Visibility(
                      visible: !widget.last,
                      child: Row(
                        children: [
                          Text(sender.name, style: theme.textTheme.titleMedium),
                          horizontalSpacing(defaultSpacing),
                          Text(
                            formatTime(widget.message.createdAt),
                            style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.secondary)
                          ),
                        ],
                      ),
                    ),
                    verticalSpacing(defaultSpacing * 0.1),
              
                    //* Content
                    Text(widget.message.content, style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.normal)),
                  ],
                ),
              ),

              horizontalSpacing(defaultSpacing),

              Visibility(
                visible: !widget.message.verified,
                child: Tooltip(
                  message: "not.signed".tr,
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.amber,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}