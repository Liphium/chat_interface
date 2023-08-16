import 'package:chat_interface/controller/chat/account/friend_controller.dart';
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
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: MouseRegion(
          onHover: (event) => widget.position.value = event.position,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            hoverColor: Theme.of(context)
                .colorScheme
                .primaryContainer,
            splashColor: Theme.of(context).hoverColor,

            //* Show profile
            onTap: () => Get.dialog(Profile(position: widget.position.value, friend: widget.friend)),

            //* Friend info
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultSpacing,
                  vertical: defaultSpacing * 0.5),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                          size: 30,
                          color: Theme.of(context)
                              .colorScheme
                              .primary),
                        const SizedBox(width: 10),
                        Text(widget.friend.name, style: Get.theme.textTheme.titleMedium),
                      ],
                    ),

                    //* Friend actions
                    Row(
                      children: [

                        //* Add to call
                        IconButton(
                          icon: Icon(Icons.add_call,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}