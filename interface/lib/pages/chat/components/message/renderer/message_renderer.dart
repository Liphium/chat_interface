
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageRenderer extends StatefulWidget {

  final String accountId;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const MessageRenderer({super.key, required this.message, required this.accountId, this.self = false, this.last = false, this.sender});

  @override
  State<MessageRenderer> createState() => _MessageRendererState();
}

class _MessageRendererState extends State<MessageRenderer> {

  final hovering = false.obs;

  @override
  Widget build(BuildContext context) {

    Friend sender = widget.sender ?? Friend.unknown(widget.accountId);
    ThemeData theme = Theme.of(context);
    widget.message.initAttachments();

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: elementSpacing,
              horizontal: sectionSpacing,
            ),
            child: Row(
              textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              
                //* Avatar
                Visibility(
                  visible: !widget.last,
                  replacement: const SizedBox(width: 34), //* Show timestamp instead
                  child: Tooltip(
                    message: sender.name,
                    child: InkWell(
                      onTap: () => sendLog("hello world"),
                      child: UserAvatar(id: sender.id, size: 34)
                    )
                  ),
                ),
                horizontalSpacing(defaultSpacing),
              
                //* Message
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                      
                    //* Content
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.5, horizontal: defaultSpacing),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        color: widget.self ? theme.colorScheme.primary : theme.colorScheme.primaryContainer,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: widget.message.content.isNotEmpty,
                            child: Text(widget.message.content, style: theme.textTheme.labelLarge)
                          ),
                        ],
                      ),
                    ),
                                    
                    //* Attachments
                    SelectionContainer.disabled(
                      child: Obx(() {
                        final renderer = widget.message.attachmentsRenderer;
                        return Visibility(
                          visible: widget.message.attachmentsRenderer.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(top: elementSpacing),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: renderer.map((e) => AttachmentRenderer(container: e)).toList(),
                            ),
                          ),
                        );
                      }),
                    ), 
                  ],
                ),
              
                horizontalSpacing(defaultSpacing),
              
                Obx(() {
                  final verified = widget.message.verified.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: elementSpacing),
                    child: Visibility(
                      visible: !verified,
                      child: Tooltip(
                        message: "chat.not.signed".tr,
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}