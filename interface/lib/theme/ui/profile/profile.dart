import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileDefaults {
  static Function(Friend, RxBool) deleteAction = (Friend friend, RxBool loading) async {
    await friend.remove(loading);
    Get.back();
  };

  static Function(Friend, RxBool) openAction = (Friend friend, RxBool loading) async {
    openConversation(loading, friend.name, [friend.id]);
  };

  static List<ProfileAction> buildDefaultActions(Friend friend) {
    final removeLoading = false.obs;

    if(friend.unknown) {
      return [
        ProfileAction(
          icon: Icons.person_add,
          category: true,
          label: 'friends.add'.tr,
          loading: false.obs,
          onTap: (f, l) => {}
        ),
      ];
    }

    return [
      ProfileAction(
        category: true,
        icon: Icons.message,
        label: 'friends.message'.tr,
        onTap: openAction,
        loading: friend.openConversationLoading
      ),
      ProfileAction(
        icon: Icons.add_call,
        label: 'friends.invite_to_space'.tr,
        loading: false.obs,
        onTap: (f, l) => {}
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

  const ProfileAction({required this.icon, required this.label, required this.loading, required this.onTap, this.category = false, this.color, this.iconColor});
  
}

class Profile extends StatefulWidget {

  final bool leftAligned;
  final Offset position;
  final Friend friend;
  final int size;
  final List<ProfileAction>Function(Friend)? actions;

  const Profile({super.key, required this.position, required this.friend, this.size = 300, this.leftAligned = true, this.actions});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  //* Loading state for buttons
  final removeLoading = false.obs;
  final List<ProfileAction> actions = [];

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    actions.clear();
    if(widget.actions == null) {
      if(widget.friend.unknown) {

      } else {
        actions.addAll(ProfileDefaults.buildDefaultActions(widget.friend));
      }
    } else {
      actions.addAll(widget.actions!(widget.friend));
    }

    //* Context menu
    return Stack(
      children: [
        Positioned(
          top: widget.position.dy,
          left: widget.leftAligned ? widget.position.dx : null,
          right: widget.leftAligned ? null : widget.position.dx,
          width: widget.size.toDouble(),
          child: Material(
            borderRadius: BorderRadius.circular(defaultSpacing),
            color: Get.theme.colorScheme.onBackground,
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
                          Icon(Icons.person, size: 30.0, color: theme.colorScheme.onPrimary),
                          horizontalSpacing(defaultSpacing),
                          Text(widget.friend.name, style: theme.textTheme.titleMedium),
                          Text("#${widget.friend.tag}", style: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.normal, color: theme.colorScheme.onPrimary)),
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
                  verticalSpacing(defaultSpacing),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: actions.length,
                    itemBuilder: (context, index) {
                      ProfileAction action = actions[index];
                      return Padding(
                        padding: EdgeInsets.only(top: index == 0 ? 0 : action.category ? defaultSpacing : elementSpacing),
                        child: ProfileButton(
                          icon: action.icon,
                          label: action.label,
                          onTap: () => action.onTap.call(widget.friend, action.loading),
                          loading: action.loading,
                          color: action.color,
                          iconColor: action.iconColor,
                        ),
                      );
                    }
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