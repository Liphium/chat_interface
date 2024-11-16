import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/image_attachment_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubblesMessageRenderer extends StatefulWidget {
  final LPHAddress senderAddress;
  final MessageProvider provider;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;
  final bool mobileLayout;
  final double? overwritePadding;

  const BubblesMessageRenderer({
    super.key,
    required this.message,
    required this.provider,
    required this.senderAddress,
    this.self = false,
    this.last = false,
    this.sender,
    this.mobileLayout = false,
    this.overwritePadding,
  });

  @override
  State<BubblesMessageRenderer> createState() => _BubblesMessageRendererState();
}

class _BubblesMessageRendererState extends State<BubblesMessageRenderer> {
  // For the context menu
  double _mouseX = 0, _mouseY = 0;

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.unknown(widget.senderAddress);

    return RepaintBoundary(
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        onHover: (event) {
          _mouseX = event.position.dx;
          _mouseY = event.position.dy;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // Detect right click to open a context menu
          onSecondaryTap: () {
            final menuData = ContextMenuData.fromPosition(Offset(_mouseX, _mouseY));

            // Open the context menu
            Get.dialog(MessageOptionsWindow(
              data: menuData,
              self: widget.message.senderAddress == StatusController.ownAddress,
              message: widget.message,
              provider: widget.provider,
            ));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: elementSpacing,
              horizontal: widget.overwritePadding ?? (widget.mobileLayout ? defaultSpacing : sectionSpacing),
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
                    message: sender.displayName.value,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => showModal(Profile(friend: sender)),
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
                        child: renderMessageContent(),
                      ),

                      //* Desktop timestamp
                      horizontalSpacing(defaultSpacing),

                      Padding(
                        padding: const EdgeInsets.only(top: defaultSpacing),
                        child: SelectionContainer.disabled(
                          child: Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                        ),
                      ),

                      //* Desktop verified indicator
                      horizontalSpacing(defaultSpacing),

                      Obx(() {
                        final verified = widget.message.verified.value;
                        return Visibility(
                          visible: !verified,
                          child: Padding(
                            padding: const EdgeInsets.only(top: elementSpacing + elementSpacing / 4),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget renderMessageContent() {
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.mobileLayout ? Get.width * 0.75 : (Get.width - 350) * 0.5),
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
                  color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    renderReplyMessage(),

                    //* Actual message (with formatted renderer)
                    FormattedText(
                      text: widget.message.content,
                      baseStyle: Get.theme.textTheme.labelLarge!,
                    ),
                  ],
                ),
              ),
            ),

            renderAttachments(),
          ],
        ),
      );
    });
  }

  Widget renderReplyMessage() {
    if (widget.message.answerMessage == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: elementSpacing, bottom: elementSpacing),
      child: Material(
        borderRadius: BorderRadius.circular(defaultSpacing),
        color: widget.self ? Get.theme.colorScheme.onPrimary.withOpacity(0.2) : Get.theme.colorScheme.inverseSurface,
        child: InkWell(
          borderRadius: BorderRadius.circular(defaultSpacing),
          onTap: () => widget.provider.scrollToMessage(widget.message.answer),
          child: Padding(
            padding: const EdgeInsets.all(elementSpacing),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                UserAvatar(id: widget.message.answerMessage!.senderAddress, size: 30),
                horizontalSpacing(elementSpacing),
                if (widget.message.answerMessage!.type == MessageType.call)
                  Icon(Icons.public, color: Get.theme.colorScheme.onPrimary)
                else if (widget.message.answerMessage!.type == MessageType.liveshare)
                  Icon(Icons.electric_bolt, color: Get.theme.colorScheme.onPrimary)
                else if (widget.message.answerMessage!.type == MessageType.system)
                  Icon(Icons.info, color: Get.theme.colorScheme.onPrimary)
                else
                  const SizedBox(),
                horizontalSpacing(elementSpacing),
                Flexible(
                  child: Text(
                    AnswerData.answerContent(
                        widget.message.answerMessage!.type, widget.message.answerMessage!.content, widget.message.answerMessage!.attachments),
                    style: Get.theme.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                horizontalSpacing(elementSpacing),
                Icon(Icons.reply, color: Get.theme.colorScheme.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget renderAttachments() {
    return SelectionContainer.disabled(
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
                  child: ImageAttachmentRenderer(
                    image: container,
                    hoverCheck: true,
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.only(top: widget.message.content.isEmpty && index == 0 ? 0 : elementSpacing),
                child: AttachmentRenderer(container: container, message: widget.message, self: widget.self),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
