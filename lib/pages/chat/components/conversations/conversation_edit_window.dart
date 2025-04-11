import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_dev_window.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ConversationInfoWindow extends StatefulWidget {
  final ContextMenuData position;
  final Conversation conversation;

  const ConversationInfoWindow({super.key, required this.position, required this.conversation});

  @override
  State<ConversationInfoWindow> createState() => _ConversationInfoWindowState();
}

class _ConversationInfoWindowState extends State<ConversationInfoWindow> {
  // Loading states
  final deleteLoading = signal(false);

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      position: widget.position,
      title: [
        Row(
          children: [
            Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
            horizontalSpacing(defaultSpacing),
            Text(
              widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.conversation.isGroup,
            child: Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(icon: Icons.edit, label: "Edit title", onTap: () => {}),
            ),
          ),
          ProfileButton(
            icon: Icons.developer_mode,
            label: "For developers",
            onTap: () => showModal(ConversationDevWindow(conversation: widget.conversation)),
          ),
          verticalSpacing(sectionSpacing),
          Text("Danger zone", style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(elementSpacing),
          Visibility(
            visible: !widget.conversation.isGroup,
            child: ProfileButton(
              color: Get.theme.colorScheme.errorContainer,
              iconColor: Get.theme.colorScheme.error,
              icon: Icons.delete,
              label: "Remove friend",
              onTap: () {
                ProfileDefaults.deleteAction.call(widget.conversation.otherMember, deleteLoading);
              },
              loading: deleteLoading,
            ),
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            color: Get.theme.colorScheme.errorContainer,
            iconColor: Get.theme.colorScheme.error,
            icon: Icons.logout,
            label: "Leave conversation",
            onTap:
                () => showConfirmPopup(
                  ConfirmWindow(
                    title: "conversations.leave".tr,
                    text: "conversations.leave.text".tr,
                    onConfirm: () {
                      widget.conversation.delete();
                      Get.back();
                    },
                    onDecline: () => {},
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
