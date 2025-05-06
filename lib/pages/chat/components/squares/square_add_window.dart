import 'dart:async';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SquareAddWindow extends StatefulWidget {
  final String title;
  final String action;
  final bool nameField;
  final List<Friend>? initial;
  final ContextMenuData? position;

  /// Called when clicking the action button (returns error text or closed on null)
  final Future<String?> Function(List<Friend>, String?)? onDone;

  const SquareAddWindow({
    super.key,
    required this.position,
    this.title = "squares.create",
    this.action = "create",
    this.nameField = true,
    this.initial,
    this.onDone,
  });

  @override
  State<SquareAddWindow> createState() => _SquareAddWindowState();

  /// Create a square using a list of friends.
  static Future<String?> createSquareAction(List<Friend> friends, String name) async {
    // Make sure the selection is valid
    if (friends.length > specialConstants[Constants.specialConstantMaxConversationMembers]!) {
      return "squares.too_many_members".trParams({
        "amount": specialConstants[Constants.specialConstantMaxConversationMembers]!.toString(),
      });
    }
    if (name.isEmpty) {
      return "squares.name_needed".tr;
    }
    if (name.length > specialConstants[Constants.specialConstantMaxConversationNameLength]!) {
      return "squares.name.length".trParams({"length": specialConstants["max_conversation_name_length"].toString()});
    }

    // Create the square
    return SquareService.openSquare(friends, name);
  }
}

class _SquareAddWindowState extends State<SquareAddWindow> {
  // State
  final _members = listSignal(<Friend>[]);
  final _conversationLoading = signal(false);
  final _errorText = signal("");
  final _search = signal("");

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
    if (!isMobileMode()) {
      _searchFocusNode.requestFocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    _controller.dispose();
    _members.dispose();
    _conversationLoading.dispose();
    _errorText.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // Only show creation menu when the user has friends
    if (FriendController.friends.length == 1) {
      return SlidingWindowBase(
        title: [Text(widget.title.tr, style: theme.textTheme.labelLarge)],
        position: widget.position,
        child: NoFriendsMessage(),
      );
    }

    return SlidingWindowBase(
      position: widget.position,
      title: [
        Text(widget.title.tr, style: theme.textTheme.labelLarge),
        const Spacer(),
        Watch((ctx) => Text("${_members.length}/100", style: theme.textTheme.bodyLarge)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector for the friends in the square
          FriendSelector(signal: _members, initial: widget.initial),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The input for naming the square
              Visibility(
                visible: widget.nameField,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing),
                  child: FJTextField(
                    controller: _controller,
                    maxLength: specialConstants[Constants.specialConstantMaxConversationNameLength],
                    hintText: "squares.name.placeholder".tr,
                  ),
                ),
              ),

              // Where an error is displayed in case one happens
              AnimatedErrorContainer(
                expand: true,
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                message: _errorText,
              ),

              // The button for creating the square
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
                  final error = await SquareAddWindow.createSquareAction(_members, _controller.text);
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
          ),
        ],
      ),
    );
  }
}
