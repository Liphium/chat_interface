import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/message_render_window.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MaterialMessageRenderer extends StatefulWidget {
  final String accountId;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const MaterialMessageRenderer({super.key, required this.message, required this.accountId, this.self = false, this.last = false, this.sender});

  @override
  State<MaterialMessageRenderer> createState() => _MaterialMessageRendererState();
}

class _MaterialMessageRendererState extends State<MaterialMessageRenderer> {
  final hovering = false.obs;

  @override
  void initState() {
    widget.message.initAttachments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.unknown(widget.accountId);
    ThemeData theme = Theme.of(context);

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(top: widget.last ? 0 : sectionSpacing),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: elementSpacing,
            horizontal: sectionSpacing,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //* Avatar
              Visibility(
                visible: !widget.last,
                replacement: const SizedBox(width: 50),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => Get.dialog(Profile(friend: sender)),
                  child: UserAvatar(id: sender.id, size: 50),
                ),
              ),
              horizontalSpacing(sectionSpacing),

              //* Message content
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Timestamp
                    SelectionContainer.disabled(
                      child: Visibility(
                        visible: !widget.last,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: elementSpacing),
                          child: Row(
                            children: [
                              Text(sender.name, style: Get.theme.textTheme.labelLarge),
                              horizontalSpacing(defaultSpacing),
                              Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ),

                    horizontalSpacing(defaultSpacing),

                    Flexible(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Column(
                          children: [
                            //* Message content (text)
                            Visibility(
                              visible: widget.message.content.isNotEmpty,
                              child: Column(
                                crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  //* Reply message
                                  Obx(() {
                                    if (widget.message.answerMessage.value == null) {
                                      return const SizedBox();
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(top: elementSpacing, bottom: elementSpacing),
                                      child: Material(
                                        borderRadius: BorderRadius.circular(defaultSpacing),
                                        color: widget.self ? theme.colorScheme.onPrimary.withOpacity(0.2) : theme.colorScheme.background,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(defaultSpacing),
                                          onTap: () => Get.dialog(MessageRenderWindow(message: widget.message.answerMessage.value!)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(elementSpacing),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                UserAvatar(id: widget.message.answerMessage.value!.senderAccount, size: 30),
                                                horizontalSpacing(elementSpacing),
                                                if (widget.message.answerMessage.value!.type == MessageType.call)
                                                  Icon(Icons.public, color: theme.colorScheme.onPrimary)
                                                else if (widget.message.answerMessage.value!.type == MessageType.liveshare)
                                                  Icon(Icons.electric_bolt, color: theme.colorScheme.onPrimary)
                                                else if (widget.message.answerMessage.value!.type == MessageType.system)
                                                  Icon(Icons.info, color: theme.colorScheme.onPrimary)
                                                else
                                                  const SizedBox(),
                                                horizontalSpacing(elementSpacing),
                                                Flexible(
                                                  child: Text(
                                                    AnswerData.answerContent(widget.message.answerMessage.value!.type, widget.message.answerMessage.value!.content,
                                                        widget.message.answerMessage.value!.attachments),
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
                                    );
                                  }),

                                  // Actual message
                                  Text(
                                    widget.message.content,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),

                            //* Attachments
                            SelectionContainer.disabled(
                              child: Obx(
                                () {
                                  final renderer = widget.message.attachmentsRenderer;
                                  return Visibility(
                                    visible: widget.message.attachmentsRenderer.isNotEmpty,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: widget.message.content.isEmpty ? 0 : elementSpacing),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: renderer.map((e) {
                                          return Padding(
                                            key: ValueKey(e.filePath),
                                            padding: const EdgeInsets.only(top: elementSpacing),
                                            child: AttachmentRenderer(container: e),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
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
      ),
    );
  }
}
