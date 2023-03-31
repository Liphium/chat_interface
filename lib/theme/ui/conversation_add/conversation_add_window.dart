import 'dart:ui';

import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/friends/friends_page.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class ConversationAddWindow extends StatefulWidget {

  final Offset position;
  
  const ConversationAddWindow({super.key, required this.position});

  @override
  State<ConversationAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ConversationAddWindow> {

  final _members = <int>[].obs;
  final _length = 0.obs;
  final _conversationLoading = false.obs;
  final _errorText = "".obs;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    FriendController friendController = Get.find();

    return Stack(
      children: [
        Positioned(
          top: widget.position.dy,
          left: widget.position.dx,
          child: SizedBox(
            width: 300,
            child: Material(
              elevation: 2.0,
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("friends.add".tr, style: theme.textTheme.titleMedium),
            
                        Obx(() =>
                          Text("${_members.length}/100", style: theme.textTheme.bodyMedium)
                        )
                      ],
                    ),
            
                    verticalSpacing(defaultSpacing * 0.5),
            
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Obx(() => ListView.builder(
                        itemCount: friendController.friends.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          Friend friend = friendController.friends.values.elementAt(index);
                                
                          return Padding(
                            padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                            child: Obx(() => Material(
                              color: _members.contains(friend.id) ? theme.colorScheme.secondaryContainer.withAlpha(100) : Colors.transparent,
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                onTap: () {
                                  if (_members.contains(friend.id)) {
                                    _members.remove(friend.id);
                                  } else {
                                    _members.add(friend.id);
                                  }
                                  _length.value = _members.length;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, size: 25, color: theme.colorScheme.primary),
                                      horizontalSpacing(defaultSpacing),
                                      Text("${friend.name}#${friend.tag}", style: theme.textTheme.bodyLarge),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                          );
                        },
                      )),
                    ),
            
                    const Divider(),
            
                    //* Create conversation button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RepaintBoundary(
                          child: Obx(() =>
                            Animate(
                        
                              effects: [
                                CustomEffect(
                                  curve: Curves.easeInOut,
                                  duration: 200.ms,
                                  builder: (context, animation, child) {
                        
                                    final height = lerpDouble(0, 50, animation);
                        
                                    return SizedBox(
                                      height: height,
                                      child: height! < 50 ? null : child
                                    );
                                  },
                                ),
                                FadeEffect(
                                  delay: 200.ms,
                                  duration: 300.ms,
                                  curve: Curves.easeInOut,  
                                ),
                                ScaleEffect(
                                  begin: const Offset(0.85,0.85),
                                  duration: 300.ms,
                                  curve: Curves.easeInOut,
                                ),
                              ],
                              target: _length.value > 1 ? 1 : 0,
                        
                              child: Material(
                                color: theme.colorScheme.secondaryContainer.withAlpha(100),
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.group),
                                    hintText: "conversations.name".tr,
                                    border: InputBorder.none
                                  ),
                                ),
                              ),
                            )
                          ),
                        ),
                        verticalSpacing(defaultSpacing * 0.5),
                        Obx(() => 
                          Visibility(
                            visible: _errorText.value.isNotEmpty,
                            child: Text(_errorText.value, 
                              style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.error)
                            ),
                          )
                        ),
                        verticalSpacing(defaultSpacing * 0.5),
                        ProfileButton(
                          icon: Icons.message,
                          onTap: () {
            
                            if(_members.isEmpty) {
                              showMessage(SnackbarType.error, "choose.members".tr);
                              return;
                            }

                            if(_controller.text.isEmpty && _members.length > 1) {
                              _errorText.value = "enter.name".tr;
                              return;
                            }
            
                            openConversation(_conversationLoading, _controller.text, _members);
                          },
                          loading: _conversationLoading,
                          label: "friends.message".tr,
                        ),
                      ],
                    )
                  ],
                ),
              )
            ),
          )
        )
      ]
    );
  }
}