import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/image_attachment_renderer.dart';
import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class MaterialMessageRenderer extends StatefulWidget {
  final LPHAddress senderAddress;
  final MessageProvider? provider;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;
  final bool mobileLayout;
  final double? overwritePadding;

  const MaterialMessageRenderer({
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
  State<MaterialMessageRenderer> createState() => _MaterialMessageRendererState();
}

class _MaterialMessageRendererState extends State<MaterialMessageRenderer> {
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
              horizontal: widget.overwritePadding ?? (widget.mobileLayout ? defaultSpacing : sectionSpacing),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Render the avatar of the user together with their name
                Row(
                  children: [
                    // Render the avatar of user
                    UserAvatar(id: sender.id, size: 34),
                    horizontalSpacing(defaultSpacing),

                    // Render the display name of the user
                    Watch(
                      (ctx) => Text(
                        sender.displayName.value,
                        style: Get.textTheme.labelLarge,
                      ),
                    ),
                    const Spacer(),

                    // Add some spacing
                    horizontalSpacing(defaultSpacing),

                    // Render the time of the sent message
                    SelectionContainer.disabled(
                      child: Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                    ),

                    // Render the verified indicator of the message
                    Watch((ctx) {
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
                verticalSpacing(elementSpacing),

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
                    ],
                  ),
                ),

                Flexible(
                  child: renderAttachments(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget renderMessageContent() {
    return Visibility(
      visible: widget.message.content.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.only(left: elementSpacing),
        child: FormattedText(
          text: widget.message.content,
          baseStyle: Get.theme.textTheme.bodyLarge!,
        ),
      ),
    );
  }

  Widget renderReplyMessage() {
    if (widget.message.answerMessage == null || widget.provider == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: elementSpacing, bottom: elementSpacing),
      child: Material(
        borderRadius: BorderRadius.circular(defaultSpacing),
        color: widget.self ? Get.theme.colorScheme.onPrimary.withAlpha(40) : Get.theme.colorScheme.inverseSurface,
        child: InkWell(
          borderRadius: BorderRadius.circular(defaultSpacing),
          onTap: () => widget.provider!.scrollToMessage(widget.message.answer),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.message.attachmentsRenderer.length, (index) {
            final container = widget.message.attachmentsRenderer[index];

            if (container.width != null && container.height != null) {
              return Padding(
                padding: EdgeInsets.only(top: elementSpacing),
                child: ImageAttachmentRenderer(
                  image: container,
                  hoverCheck: true,
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(top: elementSpacing),
              child: AttachmentRenderer(container: container, message: widget.message, self: widget.self),
            );
          }).toList(),
        ),
      ),
    );
  }
}
