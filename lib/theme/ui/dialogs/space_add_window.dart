import 'dart:async';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

import '../../../util/vertical_spacing.dart';

class SpaceAddWindow extends StatefulWidget {
  final Offset position;

  const SpaceAddWindow({super.key, required this.position});

  @override
  State<SpaceAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<SpaceAddWindow> {
  late final _public = signal(true);
  late final _conversationLoading = signal(false);

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _public.dispose();
    _conversationLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (FriendController.friends.length == 1) {
      return SlidingWindowBase(
        title: [Text("chat.space.add".tr, style: theme.textTheme.titleMedium)],
        position: ContextMenuData(widget.position, true, true),
        child: Column(
          children: [
            Text("no.friends".tr, style: theme.textTheme.bodyMedium),
            verticalSpacing(defaultSpacing),
            FJElevatedButton(
              onTap: () {
                Get.back();
                showModal(const FriendsPage());
              },
              child: Center(child: Text("open.friends".tr, style: theme.textTheme.labelLarge)),
            ),
          ],
        ),
      );
    }

    return SlidingWindowBase(
      title: [Text("chat.space.add".tr, style: theme.textTheme.titleMedium)],
      position: ContextMenuData(widget.position, true, true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
          verticalSpacing(sectionSpacing),
          Watch(
            (ctx) => FJTextField(
              controller: _controller,
              hintText: "Space name".tr,
              errorText: _errorText.value,
            ),
          ),
          */
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Public", style: Get.theme.textTheme.bodyMedium),
              Watch(
                (ctx) => FJSwitch(
                  value: _public.value,
                  onChanged: (p0) {
                    _public.value = p0;
                  },
                ),
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedLoadingButton(
            onTap: () async {
              unawaited(SpaceController.createSpace(_public.value));
              Get.back();
            },
            label: "create".tr,
            loading: _conversationLoading,
          ),
        ],
      ),
    );
  }
}
