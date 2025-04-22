import 'dart:async';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/dispose_hook.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ProfileDefaults {
  static Function(Friend, Signal<bool>) deleteAction = (Friend friend, Signal<bool> loading) async {
    // Show a confirm popup
    final result = await showConfirmPopup(
      ConfirmWindow(title: "friends.remove.confirm".tr, text: "friends.remove.desc".tr),
    );
    if (!result) {
      return;
    }

    // Remove the friend
    loading.value = true;
    final error = await friend.remove();
    if (error != null) {
      showErrorPopup("error", error);
    } else {
      Get.back();
    }
    loading.value = false;
  };

  static Function(Friend, Signal<bool>) openAction = (Friend friend, Signal<bool> loading) async {
    loading.value = true;
    final (conv, error) = await ConversationService.openDirectMessage(friend);
    if (conv != null) {
      unawaited(MessageController.openConversation(conv));
      Get.back();
    }
    if (error != null) {
      showErrorPopup("error", error);
    }
    loading.value = false;
  };

  static List<ProfileAction> buildDefaultActions(Friend friend) {
    final removeLoading = signal(false);

    if (friend.unknown) {
      return [ProfileAction(icon: Icons.person_add, category: true, label: 'friends.add'.tr, onTap: (f, l) => {})];
    }

    return [
      ProfileAction(
        category: true,
        icon: Icons.message,
        label: 'friends.message'.tr,
        onTap: openAction,
        loading: friend.openConversationLoading,
      ),
      if (SpaceController.connected.value)
        ProfileAction(
          icon: Icons.forward_to_inbox,
          label: 'friends.invite_to_space'.tr,
          loading: signal(false),
          onTap: (friend, l) {
            // Check if there even is a conversation with the guy
            final conversation = ConversationController.conversations.values.toList().firstWhereOrNull(
              (c) => c.members.values.any((m) => m.address == friend.id),
            );
            if (conversation == null) {
              showErrorPopup("error", "profile.conversation_not_found".tr);
              return;
            }

            SpaceController.inviteToCall(ConversationMessageProvider(conversation));
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
  final Signal<bool>? loading;
  final String label;
  final Color? color;
  final Color? iconColor;
  final Function(Friend, Signal<bool>) onTap;

  const ProfileAction({
    required this.icon,
    required this.label,
    this.loading,
    required this.onTap,
    this.category = false,
    this.color,
    this.iconColor,
  });
}

class Profile extends StatefulWidget {
  final bool leftAligned;
  final Offset? position;
  final Friend friend;
  final int size;
  final List<ProfileAction> Function(Friend)? actions;

  const Profile({
    super.key,
    this.position,
    required this.friend,
    this.size = 300,
    this.leftAligned = true,
    this.actions,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  //* Loading state for buttons
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
        padding: defaultSpacing,
        position: ContextMenuData(widget.position!, true, widget.leftAligned),
        maxSize: widget.size.toDouble(),
        child: buildProfile(),
      );
    } else {
      return DialogBase(title: const [], maxWidth: widget.size.toDouble(), child: buildProfile());
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
                        message: "friends.different_town".trParams({"town": widget.friend.id.server}),
                        child: Icon(Icons.sensors, color: Get.theme.colorScheme.onPrimary, size: 21),
                      ),
                    ),
                ],
              ),
            ),

            // Start space button
            LoadingIconButton(
              onTap: () {
                // Check if there even is a conversation with the guy
                final conversation = ConversationController.conversations.values.toList().firstWhereOrNull(
                  (c) => c.members.values.any((m) => m.address == widget.friend.id),
                );
                if (conversation == null) {
                  showErrorPopup("error", "profile.conversation_not_found".tr);
                  return;
                }

                // Make sure to invite the guy in case the current user is in a space
                if (SpaceController.connected.value) {
                  SpaceController.inviteToCall(ConversationMessageProvider(conversation));
                } else {
                  SpaceController.createAndConnect(ConversationMessageProvider(conversation));
                }
                Get.back();
              },
              icon: SpaceController.connected.value ? Icons.forward_to_inbox : Icons.rocket_launch,
            ),
          ],
        ),
        Watch(
          (ctx) =>
              widget.friend.status.value != ""
                  ? Text(widget.friend.status.value, style: Get.theme.textTheme.bodyMedium)
                  : const SizedBox(),
        ),
        verticalSpacing(defaultSpacing),
        ListView.builder(
          shrinkWrap: true,
          itemCount: actions.length,
          itemBuilder: (context, index) {
            ProfileAction action = actions[index];

            // Create a function that takes in a loading signal to create the button
            button(loading) => Padding(
              padding: EdgeInsets.only(
                top:
                    index == 0
                        ? 0
                        : action.category
                        ? defaultSpacing
                        : elementSpacing,
              ),
              child: ProfileButton(
                icon: action.icon,
                label: action.label,
                onTap: () => action.onTap.call(widget.friend, loading),
                loading: action.loading,
                color: action.color,
                iconColor: action.iconColor,
              ),
            );

            // Make sure to manually add the loading state in case not there
            if (action.loading == null) {
              return SignalHook(
                value: false,
                builder: (loading) {
                  return button(loading);
                },
              );
            }

            return button(action.loading);
          },
        ),
      ],
    );
  }
}
