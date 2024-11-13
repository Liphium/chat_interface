import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/controller/current/tasks/friend_sync_task.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendAddWindow extends StatefulWidget {
  const FriendAddWindow({super.key});

  @override
  State<FriendAddWindow> createState() => _FriendAddWindowState();
}

class _FriendAddWindowState extends State<FriendAddWindow> {
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text("friends.add".tr, style: Get.textTheme.labelLarge),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "friends.add.desc".tr,
            style: Get.theme.textTheme.bodyMedium,
            textAlign: TextAlign.start,
          ),
          verticalSpacing(defaultSpacing),
          FJTextField(
            controller: _name,
            hintText: 'friends.name_placeholder'.tr,
          ),
          verticalSpacing(defaultSpacing),
          Obx(
            () => FJElevatedLoadingButton(
              onTap: () {
                newFriendRequest(_name.text, (message) {
                  Get.back();
                });
              },
              label: 'friends.add.button'.tr,
              loading: (requestsLoading.value || friendsVaultRefreshing.value).obs,
            ),
          ),
        ],
      ),
    );
  }

  void doAction() {
    newFriendRequest(_name.text, (message) {
      Get.back();
    });
  }
}
