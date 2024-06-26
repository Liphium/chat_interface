import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/image_attachment_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/message_render_window.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubblesMessageRenderer extends StatefulWidget {
  final String accountId;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const BubblesMessageRenderer({
    super.key,
    required this.message,
    required this.accountId,
    this.self = false,
    this.last = false,
    this.sender,
  });

  @override
  State<BubblesMessageRenderer> createState() => _BubblesMessageRendererState();
}

class _BubblesMessageRendererState extends State<BubblesMessageRenderer> {
  final hovering = false.obs;

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.unknown(widget.accountId);
    ThemeData theme = Theme.of(context);

    return RepaintBoundary(
      child: Padding(
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
                message: sender.displayName.value.text,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => Get.dialog(Profile(friend: sender)),
                  child: UserAvatar(id: sender.id, size: 34),
                ),
              ),
            ),
            horizontalSpacing(defaultSpacing),

            //* Message content
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: (Get.width - 350) * 0.5),
                        child: Column(
                          crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            //* Message content (text)
                            Visibility(
                              visible: widget.message.content.isNotEmpty,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.5, horizontal: defaultSpacing),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(defaultSpacing),
                                  color: widget.self ? theme.colorScheme.primary : theme.colorScheme.primaryContainer,
                                ),
                                child: Column(
                                  crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    //* Reply message
                                    if (widget.message.answerMessage == null)
                                      const SizedBox()
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(top: elementSpacing, bottom: elementSpacing),
                                        child: Material(
                                          borderRadius: BorderRadius.circular(defaultSpacing),
                                          color: widget.self ? theme.colorScheme.onPrimary.withOpacity(0.2) : theme.colorScheme.inverseSurface,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(defaultSpacing),
                                            onTap: () => Get.dialog(MessageRenderWindow(message: widget.message.answerMessage!)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(elementSpacing),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  UserAvatar(id: widget.message.answerMessage!.senderAccount, size: 30),
                                                  horizontalSpacing(elementSpacing),
                                                  if (widget.message.answerMessage!.type == MessageType.call)
                                                    Icon(Icons.public, color: theme.colorScheme.onPrimary)
                                                  else if (widget.message.answerMessage!.type == MessageType.liveshare)
                                                    Icon(Icons.electric_bolt, color: theme.colorScheme.onPrimary)
                                                  else if (widget.message.answerMessage!.type == MessageType.system)
                                                    Icon(Icons.info, color: theme.colorScheme.onPrimary)
                                                  else
                                                    const SizedBox(),
                                                  horizontalSpacing(elementSpacing),
                                                  Flexible(
                                                    child: Text(
                                                      AnswerData.answerContent(widget.message.answerMessage!.type, widget.message.answerMessage!.content,
                                                          widget.message.answerMessage!.attachments),
                                                      style: Get.theme.textTheme.labelMedium,
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                  horizontalSpacing(elementSpacing),
                                                  Icon(Icons.reply, color: theme.colorScheme.onPrimary),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    //* Actual message (with formatted renderer)
                                    FormattedText(
                                      text: widget.message.content,
                                      baseStyle: theme.textTheme.labelLarge!,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            //* Attachments
                            SelectionContainer.disabled(
                              child: Visibility(
                                visible: widget.message.attachmentsRenderer.isNotEmpty,
                                child: Padding(
                                  padding: EdgeInsets.only(top: widget.message.content.isEmpty ? 0 : elementSpacing),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(widget.message.attachmentsRenderer.length, (index) {
                                      final container = widget.message.attachmentsRenderer[index];

                                      if (container.width != null && container.height != null) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: widget.message.content.isEmpty && index == 0 ? 0 : elementSpacing),
                                          child: ImageAttachmentRenderer(image: container),
                                        );
                                      }

                                      return Padding(
                                        padding: EdgeInsets.only(top: widget.message.content.isEmpty && index == 0 ? 0 : elementSpacing),
                                        child: AttachmentRenderer(container: container, message: widget.message),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),

                  horizontalSpacing(defaultSpacing),

                  //* Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: SelectionContainer.disabled(
                      child: Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                    ),
                  ),

                  horizontalSpacing(defaultSpacing),

                  //* Verified indicator
                  Obx(() {
                    final verified = widget.message.verified.value;
                    return Visibility(
                      visible: !verified,
                      child: Tooltip(
                        message: "chat.not.signed".tr,
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.amber,
                        ),
                      ),
                    );
                  })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
