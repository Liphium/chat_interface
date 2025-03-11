import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/chat/status_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ChangePasswordWindow extends StatefulWidget {
  const ChangePasswordWindow({super.key});

  @override
  State<ChangePasswordWindow> createState() => _ChangeNameWindowState();
}

class _ChangeNameWindowState extends State<ChangePasswordWindow> with SignalsMixin {
  // Text controllers
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  final _errorText = signal('');
  final _loading = signal(false);

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text("password".tr, style: Get.theme.textTheme.labelLarge),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("settings.authentication.change_password.dialog".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),

          // Current password
          Text("password.current".tr, textAlign: TextAlign.left, style: Get.theme.textTheme.labelMedium),
          verticalSpacing(elementSpacing),
          FJTextField(
            hintText: 'placeholder.password'.tr,
            obscureText: true,
            controller: _currentPasswordController,
          ),
          verticalSpacing(defaultSpacing),

          // Password
          Text("password".tr, textAlign: TextAlign.left, style: Get.theme.textTheme.labelMedium),
          verticalSpacing(elementSpacing),
          FJTextField(
            hintText: 'placeholder.password'.tr,
            obscureText: true,
            controller: _passwordController,
          ),
          verticalSpacing(defaultSpacing),
          FJTextField(
            hintText: 'placeholder.password'.tr,
            obscureText: true,
            controller: _confirmPasswordController,
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

              if (_passwordController.text.length < 8) {
                _errorText.value = 'password.invalid'.tr;
                _loading.value = false;
                return;
              }

              if (_passwordController.text != _confirmPasswordController.text) {
                _errorText.value = 'password.mismatch'.tr;
                _loading.value = false;
                return;
              }

              final json = await postAuthorizedJSON("/account/settings/change_password", {
                "current": _currentPasswordController.text,
                "new": _passwordController.text,
              });

              if (!json["success"]) {
                _errorText.value = json["error"].toString().tr;
                _loading.value = false;
                return;
              }

              // Log out of this device
              await StatusService.logOut();
            },
            child: Center(child: Text("save".tr, style: Get.theme.textTheme.labelLarge)),
          )
        ],
      ),
    );
  }
}
