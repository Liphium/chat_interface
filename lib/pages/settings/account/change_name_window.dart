import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeNameWindow extends StatefulWidget {
  const ChangeNameWindow({super.key});

  @override
  State<ChangeNameWindow> createState() => _ChangeNameWindowState();
}

class _ChangeNameWindowState extends State<ChangeNameWindow> {
  // Text controllers
  final _usernameController = TextEditingController();

  // State
  final _errorText = ''.obs;
  final _loading = false.obs;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatusController>();
    _usernameController.text = controller.name.value;

    return DialogBase(
      title: [
        Text("username".tr, style: Get.textTheme.labelLarge),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("username.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          FJTextField(
            hintText: 'placeholder.username'.tr,
            controller: _usernameController,
            maxLength: 16,
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            message: _errorText,
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            expand: true,
          ),
          FJElevatedLoadingButtonCustom(
            loading: _loading,
            onTap: () async {
              if (_loading.value) return;
              _loading.value = true;
              _errorText.value = "";

              final json = await postAuthorizedJSON("/account/settings/change_name", {
                "name": _usernameController.text,
              });

              if (!json["success"]) {
                _errorText.value = json["error"].toString().tr;
                _loading.value = false;
                return;
              }

              controller.name.value = _usernameController.text;
              _loading.value = false;
              Get.back();
            },
            child: Center(child: Text("save".tr, style: Get.theme.textTheme.labelLarge)),
          )
        ],
      ),
    );
  }
}
