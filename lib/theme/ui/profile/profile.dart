import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends StatefulWidget {

  final Offset position;
  final Friend friend;
  final int size;

  const Profile({super.key, required this.position, required this.friend, this.size = 300});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

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
                      LoadingIconButton(
                        loading: false.obs,
                        onTap: () => {},
                        icon: Icons.call
                      )
                    ],
                  ),
                  Text(widget.friend.status.value, style: theme.textTheme.bodyMedium),
                  const Divider(),
                  ProfileButton(
                    icon: Icons.message,
                    label: 'friends.message'.tr,
                    onTap: () => {},
                  ),
                  ProfileButton(
                    icon: Icons.add_call,
                    label: 'friends.add_to_call'.tr,
                    onTap: () => {},
                  ),
                  const Divider(),
                  ProfileButton(
                    icon: Icons.person_remove,
                    label: 'friends.remove'.tr,
                    onTap: () => {},
                    iconColor: Colors.red.shade300,
                    color: Colors.red.shade900.withAlpha(25)
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