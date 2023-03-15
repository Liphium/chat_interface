import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

part 'friend_actions.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final position = const Offset(0, 0).obs;

  @override
  Widget build(BuildContext context) {
    FriendController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      children: [

        //* Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
          child: Material(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.secondaryContainer,
            elevation: 2.0,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon:
                      Icon(Icons.search, color: theme.colorScheme.primary),
                  hintText: 'friends.placeholder'.tr,
                ),
              ),
            ),
          ),
        ),
        
        //* Friends list
        Expanded(
          child: Obx(() => controller.friends.isNotEmpty ? 
          
          Obx(() => 
            ListView.builder(
              padding: const EdgeInsets.all(defaultSpacing),
              itemCount: controller.friends.length,
              itemBuilder: (context, index) {
                Friend friend = controller.friends.values.elementAt(index);

                //* Friend item
                return Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    child: MouseRegion(
                      onHover: (event) => position.value = event.position,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withAlpha(100),
                        splashColor: Theme.of(context).hoverColor,

                        //* Show profile
                        onTap: () => Get.dialog(Profile(position: position.value, friend: friend,), transitionDuration: 200.ms),

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
                                    Text(friend.name, style: theme.textTheme.titleMedium),
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
              },
            )
          ) :
          
          //* No friends
          Center(
            child: Text('friends.empty'.tr, style: theme.textTheme.titleMedium),
          )),
        ),
      ],
    );
  }
}
