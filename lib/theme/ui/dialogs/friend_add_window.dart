import 'dart:ui';

import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/friends/friends_page.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class FriendAddWindow extends StatefulWidget {

  final Offset position;
  
  const FriendAddWindow({super.key, required this.position});

  @override
  State<FriendAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<FriendAddWindow> {

  final _members = <String>[].obs;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

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
                        Text("friend.add".tr, style: theme.textTheme.titleMedium),
            
                        Obx(() =>
                          Text("${_members.length}/100", style: theme.textTheme.bodyMedium)
                        )
                      ],
                    ),
            
                    verticalSpacing(defaultSpacing * 0.5),
            
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: const Placeholder()
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