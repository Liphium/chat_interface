import 'dart:async';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileDefaults {
  static Function(Friend, RxBool) deleteAction = (Friend friend, RxBool loading) async {
    // Show a confirm popup
    final result = await showConfirmPopup(ConfirmWindow(
      title: "friends.remove.confirm".tr,
      text: "friends.remove.desc".tr,
    ));
    if (!result) {
      return;
    }

    await friend.remove(loading);
    Get.back();
  };

  static Function(Friend, RxBool) openAction = (Friend friend, RxBool loading) async {
    loading.value = true;
    final (conv, error) = await ConversationService.openDirectMessage(friend);
    if (conv != null) {
      unawaited(Get.find<MessageController>().selectConversation(conv));
    }
    if (error != null) {
      showErrorPopup("error", error);
    }
    loading.value = false;
    Get.back();
  };

  static List<ProfileAction> buildDefaultActions(Friend friend) {
    final removeLoading = false.obs;

    if (friend.unknown) {
      return [
        ProfileAction(icon: Icons.person_add, category: true, label: 'friends.add'.tr, loading: false.obs, onTap: (f, l) => {}),
      ];
    }

    return [
      ProfileAction(
        category: true,
        icon: Icons.message,
        label: 'friends.message'.tr,
        onTap: openAction,
        loading: friend.openConversationLoading,
      ),
      if (SpacesController.connected.value)
        ProfileAction(
          icon: Icons.forward_to_inbox,
          label: 'friends.invite_to_space'.tr,
          loading: false.obs,
          onTap: (friend, l) {
            final controller = Get.find<ConversationController>();

            // Check if there even is a conversation with the guy
            final conversation = controller.conversations.values.toList().firstWhereOrNull(
                  (c) => c.members.values.any((m) => m.address == friend.id),
                );
            if (conversation == null) {
              showErrorPopup("error", "profile.conversation_not_found".tr);
              return;
            }

            SpacesController.inviteToCall(ConversationMessageProvider(conversation));
            Get.back();
          },
        ),
      ProfileAction(
        icon: Icons.person_remove,
        category: true,
        label: 'friends.remove'.tr,
        color: Get.theme.colorScheme.errorContainer.withAlpha(150),
        iconColor: Get.theme.colorScheme.error,
        loading: removeLoading,
        onTap: deleteAction,
      ),
    ];
  }
}

class ProfileAction {
  final IconData icon;
  final bool category;
  final RxBool loading;
  final String label;
  final Color? color;
  final Color? iconColor;
  final Function(Friend, RxBool) onTap;

  const ProfileAction(
      {required this.icon, required this.label, required this.loading, required this.onTap, this.category = false, this.color, this.iconColor});
}

class Profile extends StatefulWidget {
  final bool leftAligned;
  final Offset? position;
  final Friend friend;
  final int size;
  final List<ProfileAction> Function(Friend)? actions;

  const Profile({super.key, this.position, required this.friend, this.size = 300, this.leftAligned = true, this.actions});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //* Loading state for buttons
  final removeLoading = false.obs;
  final List<ProfileAction> actions = [];

  @override
  Widget build(BuildContext context) {
    actions.clear();
    if (widget.actions == null) {
      if (widget.friend.unknown) {
      } else {
        actions.addAll(ProfileDefaults.buildDefaultActions(widget.friend));
      }
    } else {
      actions.addAll(widget.actions!(widget.friend));
    }

    //* Context menu
    if (widget.position != null) {
      return SlidingWindowBase(
        title: const [],
        lessPadding: true,
        position: ContextMenuData(widget.position!, true, widget.leftAligned),
        maxSize: widget.size.toDouble(),
        child: buildProfile(),
      );
    } else {
      return DialogBase(
        title: const [],
        maxWidth: widget.size.toDouble(),
        child: buildProfile(),
      );
    }
  }

  Widget buildProfile() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //* Profile info
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(id: widget.friend.id, size: 40),
                  horizontalSpacing(defaultSpacing),
                  Flexible(
                    child: Text(
                      widget.friend.displayName.value,
                      overflow: TextOverflow.ellipsis,
                      style: Get.theme.textTheme.titleMedium,
                    ),
                  ),
                  if (widget.friend.id.server != basePath)
                    Padding(
                      padding: const EdgeInsets.only(left: defaultSpacing),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 500),
                        message: "friends.different_town".trParams({
                          "town": widget.friend.id.server,
                        }),
                        child: Icon(
                          Icons.sensors,
                          color: Get.theme.colorScheme.onPrimary,
                          size: 21,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Start space button
            LoadingIconButton(
              loading: false.obs,
              onTap: () {
                final controller = Get.find<ConversationController>();

                // Check if there even is a conversation with the guy
                final conversation = controller.conversations.values.toList().firstWhereOrNull(
                      (c) => c.members.values.any((m) => m.address == widget.friend.id),
                    );
                if (conversation == null) {
                  showErrorPopup("error", "profile.conversation_not_found".tr);
                  return;
                }

                // Make sure to invite the guy in case the current user is in a space
                if (SpacesController.connected.value) {
                  SpacesController.inviteToCall(ConversationMessageProvider(conversation));
                } else {
                  SpacesController.createAndConnect(ConversationMessageProvider(conversation));
                }
                Get.back();
              },
              icon: SpacesController.connected.value ? Icons.forward_to_inbox : Icons.rocket_launch,
            )
          ],
        ),
        Obx(
          () => widget.friend.status.value != ""
              ? Text(
                  widget.friend.status.value,
                  style: Get.theme.textTheme.bodyMedium,
                )
              : const SizedBox(),
        ),
        verticalSpacing(defaultSpacing),
        ListView.builder(
          shrinkWrap: true,
          itemCount: actions.length,
          itemBuilder: (context, index) {
            ProfileAction action = actions[index];
            return Padding(
              padding: EdgeInsets.only(
                  top: index == 0
                      ? 0
                      : action.category
                          ? defaultSpacing
                          : elementSpacing),
              child: ProfileButton(
                icon: action.icon,
                label: action.label,
                onTap: () => action.onTap.call(widget.friend, action.loading),
                loading: action.loading,
                color: action.color,
                iconColor: action.iconColor,
              ),
            );
          },
        ),
      ],
    );
  }
}
