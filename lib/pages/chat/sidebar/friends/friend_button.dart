import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class FriendButton extends StatefulWidget {
  final Signal<Offset> position;
  final Friend friend;

  const FriendButton({super.key, required this.friend, required this.position});

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.onInverseSurface,
      borderRadius: BorderRadius.circular(10),
      child: MouseRegion(
        onHover: (event) => widget.position.value = event.position,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),

          //* Show profile
          onTap:
              () =>
                  showModal(Profile(data: ContextMenuData.fromPosition(widget.position.value), friend: widget.friend)),

          //* Friend info
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
                    horizontalSpacing(defaultSpacing),
                    Text(widget.friend.displayName.value, style: Get.theme.textTheme.labelMedium),
                    if (widget.friend.id.server != basePath)
                      Padding(
                        padding: const EdgeInsets.only(left: defaultSpacing),
                        child: Tooltip(
                          message: "friends.different_town".trParams({"town": widget.friend.id.server}),
                          child: Icon(Icons.sensors, color: Get.theme.colorScheme.onPrimary),
                        ),
                      ),
                  ],
                ),

                // All the things that can be done with the friend
                Watch((context) {
                  // If connected to a Space, add a button to send them an invite
                  if (SpaceController.connected.value) {
                    return IconButton(
                      icon: Icon(Icons.forward_to_inbox, color: Theme.of(context).colorScheme.onPrimary),
                      onPressed: () {
                        // Check if there even is a conversation with the guy
                        final conversation = ConversationController.conversations.values.toList().firstWhereOrNull(
                          (c) => c.members.values.any((m) => m.address == widget.friend.id),
                        );
                        if (conversation == null) {
                          showErrorPopup("error", "profile.conversation_not_found".tr);
                          return;
                        }

                        // Invite the user to the current space
                        SpaceController.inviteToCall(ConversationMessageProvider(conversation));
                        Get.back();
                      },
                    );
                  }

                  // Otherwise just add a call button
                  return IconButton(
                    icon: Icon(Icons.rocket_launch, color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      // Check if there even is a conversation with the guy
                      final conversation = ConversationController.conversations.values.toList().firstWhereOrNull(
                        (c) => c.members.values.any((m) => m.address == widget.friend.id),
                      );
                      if (conversation == null) {
                        showErrorPopup("error", "profile.conversation_not_found".tr);
                        return;
                      }

                      // Invite the user to the current space
                      SpaceController.createAndConnect(ConversationMessageProvider(conversation));
                      Get.back();
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
