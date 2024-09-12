import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class SpaceAddWindow extends StatefulWidget {
  final Offset position;

  const SpaceAddWindow({super.key, required this.position});

  @override
  State<SpaceAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<SpaceAddWindow> {
  final public = true.obs;
  final _conversationLoading = false.obs;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (Get.find<FriendController>().friends.length == 1) {
      return SlidingWindowBase(
        title: [
          Text("chat.space.add".tr, style: theme.textTheme.titleMedium),
        ],
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
              child: Center(
                child: Text("open.friends".tr, style: theme.textTheme.labelLarge),
              ),
            ),
          ],
        ),
      );
    }

    return SlidingWindowBase(
      title: [
        Text("chat.space.add".tr, style: theme.textTheme.titleMedium),
      ],
      position: ContextMenuData(widget.position, true, true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
          verticalSpacing(sectionSpacing),
          Obx(
            () => FJTextField(
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
              Obx(
                () => FJSwitch(
                  value: public.value,
                  onChanged: (p0) {
                    public.value = p0;
                  },
                ),
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedLoadingButton(
            onTap: () async {
              Get.find<SpacesController>().createSpace(public.value);
              Get.back();
            },
            label: "create".tr,
            loading: _conversationLoading,
          )
        ],
      ),
    );
  }
}
