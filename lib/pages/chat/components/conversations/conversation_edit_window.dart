import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_dev_window.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_rename_window.dart';
import 'package:chat_interface/pages/chat/components/squares/topic_manage_window.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/theme/ui/conversation_util.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ConversationEditWindow extends StatefulWidget {
  final ContextMenuData position;
  final Conversation conversation;
  final String extra;

  const ConversationEditWindow({super.key, required this.position, required this.conversation, this.extra = ""});

  @override
  State<ConversationEditWindow> createState() => _ConversationEditWindowState();
}

class _ConversationEditWindowState extends State<ConversationEditWindow> {
  // Loading states
  final deleteLoading = signal(false);

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      position: widget.position,
      title: [
        Row(
          children: [
            Icon(
              ConversationUtil.getIconForConversation(widget.conversation, extra: widget.extra),
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            horizontalSpacing(defaultSpacing),
            Text(
              ConversationUtil.getNameForConversation(widget.conversation, extra: widget.extra),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render a button for changing the title of the conversation/square (only when no topic)
          Visibility(
            visible: widget.conversation.isGroup && widget.extra == "",
            child: Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(
                icon: Icons.edit,
                label: "conversations.name.edit".tr,
                onTap: () {
                  Get.back();
                  Get.dialog(ConversationRenameWindow(conversation: widget.conversation));
                },
              ),
            ),
          ),

          // Render a button for editing the topic (only when one is there)
          Visibility(
            visible: widget.extra != "",
            child: Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(
                icon: Icons.edit,
                label: "squares.topics.edit".tr,
                onTap: () {
                  // Get the topic
                  final container = widget.conversation.container as SquareContainer;
                  final topic = container.topics.firstWhereOrNull((t) => t.id == widget.extra);
                  if (topic == null) {
                    showErrorPopup("error", "not.found".tr);
                    return;
                  }

                  // Open the window to manage the topic
                  Get.back();
                  Get.dialog(TopicManageWindow(square: widget.conversation as Square, toEdit: topic));
                },
              ),
            ),
          ),
          ProfileButton(
            icon: Icons.developer_mode,
            label: "For developers",
            onTap: () {
              Get.back();
              showModal(ConversationDevWindow(conversation: widget.conversation));
            },
          ),
          verticalSpacing(sectionSpacing),
          Text("Danger zone", style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(elementSpacing),

          // Create a button for deleting the topic (in case we are editing one)
          Visibility(
            visible: widget.extra != "",
            child: Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                color: Get.theme.colorScheme.errorContainer,
                iconColor: Get.theme.colorScheme.error,
                icon: Icons.delete,
                label: "squares.topics.delete".tr,
                loading: deleteLoading,
                onTap: () async {
                  deleteLoading.value = true;
                  final error = await SquareService.deleteTopic(widget.conversation as Square, widget.extra);
                  deleteLoading.value = false;
                  if (error != null) {
                    showErrorPopup("error", error);
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
          ),

          // Create a button for leaving the conversation (only show when not a topic)
          Visibility(
            visible: widget.extra == "",
            child: Padding(
              padding: const EdgeInsets.only(top: elementSpacing),
              child: ProfileButton(
                color: Get.theme.colorScheme.errorContainer,
                iconColor: Get.theme.colorScheme.error,
                icon: Icons.logout,
                label: "conversations.leave".tr,
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
            ),
          ),
        ],
      ),
    );
  }
}
