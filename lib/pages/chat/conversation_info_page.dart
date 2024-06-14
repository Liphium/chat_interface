import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_info_window.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationInfoPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationInfoPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ConversationInfoPage> createState() => _ConversationInfoPageState();
}

class _ConversationInfoPageState extends State<ConversationInfoPage> {
  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text(
          widget.conversation.dmName,
          style: Get.theme.textTheme.labelLarge,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "chat.members".trParams({"count": widget.conversation.members.length.toString()}),
            style: Get.theme.textTheme.bodyMedium,
          ),
          verticalSpacing(defaultSpacing),
          Column(
            children: List.generate(widget.conversation.members.length, (index) {
              final member = widget.conversation.members.values.elementAt(index).getFriend();
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : elementSpacing),
                child: Material(
                  color: Get.theme.colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    onTap: () => showModal(Profile(friend: member)),
                    child: Padding(
                      padding: const EdgeInsets.all(defaultSpacing),
                      child: UserRenderer(id: member.id),
                    ),
                  ),
                ),
              );
            }),
          ),
          verticalSpacing(sectionSpacing),
          Text(
            "Actions",
            style: Get.theme.textTheme.bodyMedium,
          ),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.edit,
            label: "Edit title",
            onTap: () => {},
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.person,
            label: "View profile",
            onTap: () => {},
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.developer_mode,
            label: "For developers",
            onTap: () => showModal(ConversationInfoWindow(conversation: widget.conversation)),
            loading: false.obs,
          ),
          verticalSpacing(sectionSpacing),
          Text(
            "Danger zone",
            style: Get.theme.textTheme.bodyMedium,
          ),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            color: Get.theme.colorScheme.errorContainer,
            iconColor: Get.theme.colorScheme.error,
            icon: Icons.delete,
            label: "Remove friend",
            onTap: () => {},
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            color: Get.theme.colorScheme.errorContainer,
            iconColor: Get.theme.colorScheme.error,
            icon: Icons.logout,
            label: "Leave conversation",
            onTap: () => {},
            loading: false.obs,
          ),
        ],
      ),
    );
  }
}
