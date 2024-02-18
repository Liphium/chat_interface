import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageRenderWindow extends StatefulWidget {
  final Message message;

  const MessageRenderWindow({super.key, required this.message});

  @override
  State<MessageRenderWindow> createState() => _MessageRenderWindowState();
}

class _MessageRenderWindowState extends State<MessageRenderWindow> {
  final answerMessage = Rx<Message?>(null);

  @override
  void initState() {
    super.initState();
    loadAnswer();
  }

  void loadAnswer() async {
    if (widget.message.answer != "") {
      final message = await (db.message.select()
            ..where((tbl) => tbl.id.equals(widget.message.answer))
            ..where((tbl) => tbl.conversationId.equals(widget.message.conversation)))
          .getSingleOrNull();
      if (message != null) {
        answerMessage.value = Message.fromMessageData(message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friend = Get.find<FriendController>().friends[widget.message.senderAccount] ?? Friend.unknown(widget.message.senderAccount);
    widget.message.initAttachments();

    return DialogBase(
      maxWidth: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author
          Row(
            children: [
              UserAvatar(id: widget.message.senderAccount, size: 32),
              horizontalSpacing(defaultSpacing),
              Text(
                "${friend.name} (${friend.id})",
                style: Get.textTheme.labelLarge,
              ),
              const Expanded(child: SizedBox()),
              Text(
                "${formatDay(widget.message.createdAt)}, ${formatMessageTime(widget.message.createdAt)}",
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ),

          // Message
          if (widget.message.type == MessageType.text && widget.message.content != "")
            Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: Text(
                widget.message.content,
                style: Get.textTheme.labelLarge,
              ),
            ),

          // Attachments
          if (widget.message.attachments.isNotEmpty)
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                itemCount: widget.message.attachmentsRenderer.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: AttachmentRenderer(container: widget.message.attachmentsRenderer[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
