import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as ent;
import 'package:chat_interface/pages/chat/components/conversations/conversation_dev_window.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ConversationInfoMobile extends StatefulWidget {
  final ContextMenuData position;
  final Conversation conversation;

  const ConversationInfoMobile({
    super.key,
    required this.position,
    required this.conversation,
  });

  @override
  State<ConversationInfoMobile> createState() => _ConversationInfoMobileState();
}

class _ConversationInfoMobileState extends State<ConversationInfoMobile> {
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
          // Show basic information about the conversation
          Text(
            "conversation.info.town".trParams({
              "town": widget.conversation.id.server,
            }),
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(sectionSpacing),

          // Show things that can be done with the current conversation
          Text(
            "Actions",
            style: Get.theme.textTheme.labelMedium,
          ),
          verticalSpacing(defaultSpacing),

          // The conversation search is here to make it easier to access
          ProfileButton(
            icon: Icons.search,
            label: "chat.search".tr,
            onTap: () => showModal(ConversationDevWindow(conversation: widget.conversation)),
          ),
          verticalSpacing(elementSpacing),

          // Only show Zap when this is a direct message
          Visibility(
            visible: widget.conversation.type == ent.ConversationType.directMessage,
            child: Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(
                icon: Icons.electric_bolt,
                label: "chat.zapshare".tr,
                onTap: () => ZapShareController.openWindow(widget.conversation, ContextMenuData.fromPosition(Offset.zero)),
              ),
            ),
          ),
          Visibility(
            visible: widget.conversation.isGroup,
            child: Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: ProfileButton(
                icon: Icons.edit,
                label: "Edit title",
                onTap: () => {},
              ),
            ),
          ),
          ProfileButton(
            icon: Icons.developer_mode,
            label: "dev.details".tr,
            onTap: () => showModal(ConversationDevWindow(conversation: widget.conversation)),
          ),
          verticalSpacing(sectionSpacing),

          // Show that the conversation is encrypted (to make the user feel safe ig)
          Text(
            "Encryption",
            style: Get.theme.textTheme.labelMedium,
          ),
          verticalSpacing(defaultSpacing),
          Text("conversation.info.encrypted".tr, style: Get.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),

          // Make sure they have the ability to learn more in case they want to
          ProfileButton(
            icon: Icons.launch,
            label: "learn_more".tr,
            onTap: () => launchUrlString(Constants.docsEncryptionAndPrivacy),
          ),

          verticalSpacing(sectionSpacing),
          Text(
            "Danger zone",
            style: Get.theme.textTheme.labelMedium,
          ),
          verticalSpacing(defaultSpacing),
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
            onTap: () => showConfirmPopup(ConfirmWindow(
              title: "conversations.leave".tr,
              text: "conversations.leave.text".tr,
              onConfirm: () {
                widget.conversation.delete();
                Get.back();
              },
              onDecline: () => {},
            )),
          ),
        ],
      ),
    );
  }
}
