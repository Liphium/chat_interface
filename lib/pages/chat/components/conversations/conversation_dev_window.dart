import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ConversationDevWindow extends StatefulWidget {
  final Conversation conversation;

  const ConversationDevWindow({super.key, required this.conversation});

  @override
  State<ConversationDevWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ConversationDevWindow> {
  final messageDeletionLoading = signal(false);

  @override
  Widget build(BuildContext context) {
    final readDate = DateTime.fromMillisecondsSinceEpoch(widget.conversation.readAt.value.toInt());
    final updateDate = DateTime.fromMillisecondsSinceEpoch(widget.conversation.updatedAt.value.toInt());
    sendLog(widget.conversation.lastVersion);

    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "conversation.info.id".trParams({
              "id": widget.conversation.id.toString(),
            }),
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(elementSpacing),
          Text(
            "conversation.info.read".trParams({
              "clock": "message.time".trParams({
                "hour": readDate.hour.toString().padLeft(2, "0"),
                "minute": readDate.minute.toString().padLeft(2, "0"),
              }),
              "date": "time".trParams({
                "day": readDate.day.toString().padLeft(2, "0"),
                "month": readDate.month.toString().padLeft(2, "0"),
                "year": readDate.year.toString().padLeft(2, "0"),
              }),
            }),
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(elementSpacing),
          Text(
            "conversation.info.update".trParams({
              "clock": "message.time".trParams({
                "hour": updateDate.hour.toString().padLeft(2, "0"),
                "minute": updateDate.minute.toString().padLeft(2, "0"),
              }),
              "date": "time".trParams({
                "day": updateDate.day.toString().padLeft(2, "0"),
                "month": updateDate.month.toString().padLeft(2, "0"),
                "year": updateDate.year.toString().padLeft(2, "0"),
              }),
            }),
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(elementSpacing),
          Text(
            "conversation.info.members".trParams({
              "count": widget.conversation.members.length.toString(),
            }),
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(elementSpacing),
          Text(
            "conversation.info.version".trParams({
              "version": widget.conversation.lastVersion.toString(),
            }),
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.copy,
            label: "conversation.info.copy_id".tr,
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.conversation.id.toString()));
              Get.back();
            },
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.copy,
            label: "conversation.info.copy_token".tr,
            onTap: () {
              Clipboard.setData(ClipboardData(text: "${widget.conversation.token.id}:${widget.conversation.token.token}"));
              Get.back();
            },
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            color: Get.theme.colorScheme.onError,
            iconColor: Get.theme.colorScheme.error,
            icon: Icons.close,
            label: "close".tr,
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
