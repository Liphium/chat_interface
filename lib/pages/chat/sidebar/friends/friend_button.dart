import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendButton extends StatefulWidget {
  final Rx<Offset> position;
  final Friend friend;

  const FriendButton({super.key, required this.friend, required this.position});

  @override
  State<FriendButton> createState() => _FriendButtonState();
}

class _FriendButtonState extends State<FriendButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(10),
      child: MouseRegion(
        onHover: (event) => widget.position.value = event.position,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: Theme.of(context).colorScheme.primary.withAlpha(100),
          splashColor: Theme.of(context).hoverColor,

          //* Show profile
          onTap: () => showModal(Profile(position: widget.position.value, friend: widget.friend)),

          //* Friend info
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.5),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Icon(Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 10),
                  Text(widget.friend.displayName.value.text, style: Get.theme.textTheme.labelMedium),
                ],
              ),

              //* Friend actions
              Builder(builder: (context) {
                if (Get.find<SpacesController>().inSpace.value) {
                  return IconButton(
                    icon: Icon(Icons.add_call, color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      final conversation = Get.find<ConversationController>()
                          .conversations
                          .values
                          .where((element) => !element.isGroup && element.members.containsKey(widget.friend.id));
                      if (conversation.isNotEmpty) {
                        Get.find<SpacesController>().inviteToCall(conversation.first.id);
                        Get.back();
                      }
                    },
                  );
                }

                return IconButton(
                  icon: Icon(Icons.call, color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    final conversation = Get.find<ConversationController>().conversations.values.where(
                          (element) => !element.isGroup && element.members.values.any((m) => m.address == widget.friend.id),
                        );
                    if (conversation.isNotEmpty) {
                      Get.find<SpacesController>().createAndConnect(conversation.first.id);
                      Get.back();
                    }
                  },
                );
              }),
            ]),
          ),
        ),
      ),
    );
  }
}
