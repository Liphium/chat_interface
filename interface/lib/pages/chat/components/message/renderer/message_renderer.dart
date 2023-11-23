
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
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
          padding: const EdgeInsets.symmetric(
            vertical: elementSpacing,
            horizontal: sectionSpacing,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //* Avatar
              Visibility(
                visible: !widget.last,
                replacement: const SizedBox(width: 50), //* Show timestamp instead
                child: UserAvatar(id: sender.id, size: 50),
              ),
              horizontalSpacing(sectionSpacing),

              //* Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
                    //* Message info
                    Visibility(
                      visible: !widget.last,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sender.name, 
                            style: theme.textTheme.titleLarge,
                          ),
                          horizontalSpacing(defaultSpacing),
                          Text(
                            formatTime(widget.message.createdAt),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
              
                    //* Content
                    Text(widget.message.content, style: theme.textTheme.bodyLarge)
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