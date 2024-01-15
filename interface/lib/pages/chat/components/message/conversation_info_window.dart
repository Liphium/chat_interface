import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConversationInfoWindow extends StatefulWidget {
  final Conversation conversation;

  const ConversationInfoWindow({super.key, required this.conversation});

  @override
  State<ConversationInfoWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ConversationInfoWindow> {
  final messageDeletionLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final readDate = DateTime.fromMicrosecondsSinceEpoch(widget.conversation.readAt.value.toInt());

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
                "hour": readDate.hour.toString(),
                "minute": readDate.minute.toString(),
              }),
              "date": "time".trParams({
                "day": readDate.day.toString(),
                "month": readDate.month.toString(),
                "year": readDate.year.toString(),
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
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.copy,
            label: "conversation.info.copy_id".tr,
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.conversation.id.toString()));
              Get.back();
            },
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.copy,
            label: "conversation.info.copy_token".tr,
            onTap: () {
              Clipboard.setData(ClipboardData(text: "${widget.conversation.token.id}:${widget.conversation.token.token}"));
              Get.back();
            },
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            color: Get.theme.colorScheme.onError,
            iconColor: Get.theme.colorScheme.error,
            icon: Icons.close,
            label: "close".tr,
            onTap: () => Get.back(),
            loading: false.obs,
          ),
        ],
      ),
    );
  }
}
