import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_dev_window.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationInfoPage extends StatefulWidget {
  final bool showMembers;
  final ContextMenuData position;
  final Conversation conversation;

  const ConversationInfoPage({
    super.key,
    required this.position,
    required this.conversation,
    this.showMembers = true,
  });

  @override
  State<ConversationInfoPage> createState() => _ConversationInfoPageState();
}

class _ConversationInfoPageState extends State<ConversationInfoPage> {
  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      position: widget.position,
      title: [
        Row(
          children: [
            Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
            horizontalSpacing(defaultSpacing),
            Text(widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.showMembers,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
              ],
            ),
          ),
          Visibility(
            visible: widget.showMembers,
            child: Padding(
              padding: const EdgeInsets.only(bottom: defaultSpacing),
              child: Text(
                "Actions",
                style: Get.theme.textTheme.bodyMedium,
              ),
            ),
          ),
          Visibility(
            visible: widget.conversation.isGroup,
            replacement: ProfileButton(
              icon: Icons.person,
              label: "View profile",
              onTap: () => Get.dialog(Profile(friend: widget.conversation.otherMember)),
              loading: false.obs,
            ),
            child: ProfileButton(
              icon: Icons.edit,
              label: "Edit title",
              onTap: () => {},
              loading: false.obs,
            ),
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
          verticalSpacing(elementSpacing),
          Visibility(
            visible: !widget.conversation.isGroup,
            child: ProfileButton(
              color: Get.theme.colorScheme.errorContainer,
              iconColor: Get.theme.colorScheme.error,
              icon: Icons.delete,
              label: "Remove friend",
              onTap: () => {},
              loading: false.obs,
            ),
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
