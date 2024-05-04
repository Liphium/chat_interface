import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class ConversationAddWindow extends StatefulWidget {
  final String title;
  final String action;
  final bool nameField;
  final List<Friend>? initial;
  final ContextMenuData position;

  /// Called when clicking the action button (returns error text or closed on null)
  final Future<String?> Function(List<Friend>, String?)? onDone;

  const ConversationAddWindow({
    super.key,
    required this.position,
    this.title = "conversations.create",
    this.action = "create",
    this.nameField = true,
    this.initial,
    this.onDone,
  });

  @override
  State<ConversationAddWindow> createState() => _ConversationAddWindowState();

  static Future<String?> createConversationAction(List<Friend> friends, String? name) async {
    if (friends.isEmpty) {
      return "choose.members".tr;
    }

    if (friends.length > specialConstants["max_conversation_members"]) {
      return "choose.members".tr;
    }

    if (name == null && friends.length > 1) {
      return "enter.name".tr;
    }

    if (name!.isEmpty && friends.length > 1) {
      return "enter.name".tr;
    }

    if (name.length > specialConstants["max_conversation_name_length"] && friends.length > 1) {
      return "too.long".trParams({"limit": specialConstants["max_conversation_name_length"].toString()});
    }

    var result = false;
    if (friends.length == 1) {
      result = await openDirectMessage(friends.first);
    } else {
      result = await openGroupConversation(friends, name);
    }

    return result ? null : "server.error".tr;
  }
}

class _ConversationAddWindowState extends State<ConversationAddWindow> {
  // State
  final _members = <Friend>[].obs;
  final _length = 0.obs;
  final _conversationLoading = false.obs;
  final _errorText = "".obs;
  final _search = "".obs;

  // Input
  final _searchFocusNode = FocusNode();
  final _searchController = TextEditingController();
  final _controller = TextEditingController();

  @override
  void initState() {
    if (widget.initial != null) {
      for (var friend in widget.initial!) {
        _members.add(friend);
      }
    }
    _searchFocusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    FriendController friendController = Get.find();

    if (friendController.friends.length == 1) {
      return SlidingWindowBase(
        position: widget.position,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("no.friends".tr, style: theme.textTheme.bodyMedium),
            verticalSpacing(defaultSpacing),
            FJElevatedButton(
              onTap: () {
                Get.back();
                Get.dialog(const FriendsPage());
              },
              child: Center(
                child: Text("open.friends".tr, style: theme.textTheme.labelLarge),
              ),
            ),
          ],
        ),
      );
    }

    return SlidingWindowBase(
      position: widget.position,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(widget.title.tr, style: theme.textTheme.titleMedium), Obx(() => Text("${_members.length}/100", style: theme.textTheme.bodyMedium))],
          ),
          verticalSpacing(defaultSpacing),

          //* Input
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(defaultSpacing),
            ),
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
            child: Row(
              children: [
                Icon(Icons.search, size: 25, color: theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'search'.tr,
                    ),
                    cursorColor: theme.colorScheme.onPrimary,
                    style: theme.textTheme.labelLarge,
                    onChanged: (value) => _search.value = value,
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onSubmitted: (value) {
                      // Make the first friend that matches the search the selected one
                      if (friendController.friends.isNotEmpty) {
                        final member = friendController.friends.values.firstWhere(
                          (element) => element.name.toLowerCase().contains(value.toLowerCase()) && element.id != StatusController.ownAccountId,
                          orElse: () => Friend.unknown("-"),
                        );
                        if (member.id != "-") {
                          if (_members.contains(member)) {
                            _members.remove(member);
                          } else if (member.id != StatusController.ownAccountId) {
                            _members.add(member);
                          }
                        }
                        _length.value = _members.length;

                        _search.value = "";
                        _searchController.clear();
                        _searchFocusNode.requestFocus();
                      }
                    },
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Obx(
              () => ListView.builder(
                itemCount: friendController.friends.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: defaultSpacing),
                itemBuilder: (context, index) {
                  Friend friend = friendController.friends.values.elementAt(index);

                  if (friend.id == StatusController.ownAccountId) {
                    return const SizedBox();
                  }

                  return Obx(() {
                    final search = _search.value;
                    if (search.isNotEmpty && !friend.name.toLowerCase().contains(_search.value.toLowerCase())) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: defaultSpacing),
                      child: Obx(
                        () => Material(
                          color: _members.contains(friend) ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            onTap: () {
                              if (widget.initial != null && widget.initial!.contains(friend)) {
                                return;
                              }
                              if (_members.contains(friend)) {
                                _members.remove(friend);
                              } else {
                                _members.add(friend);
                              }
                              _length.value = _members.length;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: elementSpacing, vertical: elementSpacing),
                              child: Row(
                                children: [
                                  UserAvatar(
                                    id: friend.id,
                                    size: 35,
                                  ),
                                  horizontalSpacing(defaultSpacing),
                                  Text(friend.name, style: theme.textTheme.labelLarge),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),

          //* Create conversation button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.nameField,
                child: RepaintBoundary(
                  child: Obx(
                    () => Animate(
                      effects: [
                        ExpandEffect(axis: Axis.vertical, duration: 250.ms, curve: Curves.ease, alignment: Alignment.center),
                      ],
                      target: _length.value > 1 ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing),
                        child: FJTextField(
                          controller: _controller,
                          hintText: "conversations.name".tr,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedErrorContainer(
                expand: true,
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                message: _errorText,
              ),
              FJElevatedLoadingButton(
                onTap: () async {
                  _conversationLoading.value = true;
                  if (widget.onDone != null) {
                    final error = await widget.onDone!(_members, _controller.text);
                    if (error != null) {
                      _errorText.value = error;
                    } else {
                      Get.back();
                    }
                    _conversationLoading.value = false;
                    return;
                  }
                  final error = await ConversationAddWindow.createConversationAction(_members, _controller.text);
                  if (error != null) {
                    _errorText.value = error;
                  } else {
                    Get.back();
                  }
                  _conversationLoading.value = false;
                },
                label: widget.action.tr,
                loading: _conversationLoading,
              ),
            ],
          )
        ],
      ),
    );
  }
}
