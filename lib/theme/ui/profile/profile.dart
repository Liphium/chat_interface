import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../pages/chat/sidebar/tabs/friends/friends_page.dart';

class Profile extends StatefulWidget {

  final Offset position;
  final Friend friend;
  final int size;

  const Profile({super.key, required this.position, required this.friend, this.size = 300});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  //* Loading state for buttons
  final removeLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    //* Context menu
    return Stack(
      children: [
        Positioned(
          top: widget.position.dy,
          left: widget.position.dx,
          width: widget.size.toDouble(),
          child: Material(
            borderRadius: BorderRadius.circular(defaultSpacing),
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
            
                      //* Profile info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 30.0, color: theme.colorScheme.primary),
                          horizontalSpacing(defaultSpacing),
                          Text(widget.friend.name, style: theme.textTheme.titleMedium),
                          Text("#${widget.friend.tag}", style: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.normal, color: theme.colorScheme.primary)),
                        ],
                      ),
            
                      //* Call button
                      LoadingIconButton(
                        loading: false.obs,
                        onTap: () => {},
                        icon: Icons.call
                      )
                    ],
                  ),
                  Text(widget.friend.status.value, style: theme.textTheme.bodyMedium),
                  Divider(
                    color: theme.dividerColor,
                  ),
            
                  //* Create conversation
                  ProfileButton(
                    icon: Icons.message,
                    label: 'friends.message'.tr,
                    onTap: () => openConversation(widget.friend.openConversationLoading, widget.friend.name, [widget.friend.id]),
                    loading: widget.friend.openConversationLoading
                  ),
            
                  //* Add to call
                  ProfileButton(
                    icon: Icons.add_call,
                    label: 'friends.add_to_call'.tr,
                    onTap: () => {},
                    loading: false.obs
                  ),
                  Divider(
                    color: theme.dividerColor,
                  ),
            
                  //* Remove friend
                  ProfileButton(
                    icon: Icons.person_remove,
                    label: 'friends.remove'.tr,
                    onTap: () => widget.friend.remove(removeLoading),
                    iconColor: Colors.red.shade300,
                    color: Colors.red.shade900.withAlpha(25),
                    loading: removeLoading
                  ),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }
}