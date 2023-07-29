
import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/friend_add_window.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'friend_actions.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {

  final position = const Offset(0, 0).obs;
  final GlobalKey _addKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    FriendController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      children: [

        SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildInput(theme),
                horizontalSpacing(defaultSpacing * 0.5),
                SizedBox(
                  key: _addKey,
                  width: 48,
                  height: 48,
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(defaultSpacing * 1.5),
                    ),
                    color: theme.colorScheme.primaryContainer,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(defaultSpacing),
                      ),
                      onTap: () {
                        final RenderBox box = _addKey.currentContext?.findRenderObject() as RenderBox;
          
                        //* Open conversation add window
                        Get.dialog(FriendAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Icon(Icons.add, color: theme.colorScheme.primary),
                      ),
                    )
                  ),
                ),
              ],
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
                            .withAlpha(150),
                        splashColor: Theme.of(context).hoverColor,

                        //* Show profile
                        onTap: () => Get.dialog(Profile(position: position.value, friend: friend)),

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

  Widget buildInput(ThemeData theme) {
    return Expanded(
      child: Material(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(defaultSpacing * 1.5),
        ),
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
              hintText: 'friends.placeholder'.tr,
            ),
          ),
        ),
      ),
    );
  }
}
