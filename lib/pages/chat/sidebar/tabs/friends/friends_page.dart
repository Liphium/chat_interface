
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/friends/friend_button.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/friends/request_button.dart';
import 'package:chat_interface/theme/ui/dialogs/friend_add_window.dart';
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
          
                        //* Open friend add window
                        Get.dialog(FriendAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                      },
                      child: Icon(Icons.add, color: theme.colorScheme.primary),
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
        
        //* Friends list
        Expanded(
          child: RepaintBoundary(
            child: GetX<FriendController>(
              builder: (friendController) {
                final friendsEmpty = friendController.friends.isEmpty;
                return GetX<RequestController>(
                  builder: (requestController) {
                    final empty = requestController.requests.isEmpty && friendsEmpty && requestController.requestsSent.isEmpty;
                    if(empty) {
                      return Center(
                        child: Text('friends.empty'.tr, style: theme.textTheme.titleMedium),
                      );
                    }
            
                    //* Friends, requests, sent requests list
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                      child: Column(
                        children: [
                          verticalSpacing(defaultSpacing),
                          //* Requests
                          Visibility(
                            visible: requestController.requests.isNotEmpty,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                                  child: Text("friends.requests".tr, style: theme.textTheme.labelLarge),
                                ),
                                verticalSpacing(elementSpacing),
                                Builder(
                                  builder: (context) {
                                    if (requestController.requests.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: requestController.requests.map((request) {
                                        return RequestButton(request: request, self: false);
                                      }).toList(),
                                    );
                                  },
                                ),
                                verticalSpacing(sectionSpacing),
                              ],
                            )
                          ),
                              
                          //* Sent requests
                          Visibility(
                            visible: requestController.requestsSent.isNotEmpty,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                                  child: Text("friends.requestsSent".tr, style: theme.textTheme.labelLarge),
                                ),                                
                                verticalSpacing(elementSpacing),
                                Builder(
                                  builder: (context) {
                                    if (requestController.requestsSent.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: requestController.requestsSent.map((request) {
                                        return RequestButton(request: request, self: true);
                                      }).toList(),
                                    );
                                  },
                                ),
                                verticalSpacing(sectionSpacing),
                              ],
                            )
                          ),
                              
                          //* Friends
                          Visibility(
                            visible: friendController.friends.isNotEmpty,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (context) {
                                    if (friendController.friends.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: friendController.friends.values.map((friend) {
                                        return FriendButton(friend: friend, position: position);
                                      }).toList(),
                                    );
                                  },
                                ),
                                verticalSpacing(sectionSpacing),
                              ],
                            )
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
