import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class MessageInfoWindow extends StatefulWidget {
  final Message message;

  const MessageInfoWindow({super.key, required this.message});

  @override
  State<MessageInfoWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<MessageInfoWindow> {
  final messageDeletionLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final conversationToken = Get.find<ConversationController>().conversations[widget.message.conversation]!.members[widget.message.sender] ??
        Member(LPHAddress("", "removed".tr), widget.message.senderAddress, MemberRole.user);

    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "message.info.text".trParams({
              "account": conversationToken.address.encode(),
              "token": conversationToken.tokenId.encode(),
              "hour": widget.message.createdAt.hour.toString(),
              "minute": widget.message.createdAt.minute.toString(),
              "day": widget.message.createdAt.day.toString(),
              "month": widget.message.createdAt.month.toString(),
              "year": widget.message.createdAt.year.toString(),
            }),
            style: Get.textTheme.bodyMedium,
          ),

          // Buttons
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.copy,
            label: "message.info.copy_id".tr,
            onTap: () {
              Clipboard.setData(ClipboardData(text: widget.message.id));
              Get.back();
            },
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.copy,
            label: "message.info.copy_sender".tr,
            onTap: () {
              Clipboard.setData(ClipboardData(text: conversationToken.tokenId.encode()));
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
