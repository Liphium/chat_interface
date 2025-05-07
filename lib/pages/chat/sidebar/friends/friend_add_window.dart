import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/account/requests_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class FriendAddWindow extends StatefulWidget {
  final String? name;

  const FriendAddWindow({super.key, this.name});

  @override
  State<FriendAddWindow> createState() => _FriendAddWindowState();
}

class _FriendAddWindowState extends State<FriendAddWindow> {
  final TextEditingController _name = TextEditingController();

  @override
  void initState() {
    if (widget.name != null) {
      _name.text = widget.name ?? "";
    }
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void sendRequest() {
    if (RequestController.requestsLoading.value || FriendsVault.friendsVaultRefreshing.value) {
      return;
    }
    newFriendRequest(_name.text, (message) {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("friends.add".tr, style: Get.textTheme.labelLarge)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("friends.add.desc".tr, style: Get.theme.textTheme.bodyMedium, textAlign: TextAlign.start),
          verticalSpacing(defaultSpacing),
          FJTextField(
            controller: _name,
            hintText: 'friends.name_placeholder'.tr,
            autofocus: true,
            onSubmitted: (t) => sendRequest(),
          ),
          verticalSpacing(defaultSpacing),
          Watch(
            (ctx) => FJElevatedLoadingButton(
              onTap: () => sendRequest(),
              label: 'friends.add.button'.tr,
              loading: computed(
                () => RequestController.requestsLoading.value || FriendsVault.friendsVaultRefreshing.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
