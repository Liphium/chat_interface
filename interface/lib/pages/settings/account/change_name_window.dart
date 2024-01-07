import 'dart:async';

import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ChangeNameWindow extends StatefulWidget {
  const ChangeNameWindow({super.key});

  @override
  State<ChangeNameWindow> createState() => _ChangeNameWindowState();
}

class _ChangeNameWindowState extends State<ChangeNameWindow> {
  // Text controllers
  final _usernameController = TextEditingController();
  final _tagController = TextEditingController();

  // State
  final _errorText = ''.obs;
  final _loading = false.obs;

  @override
  void dispose() {
    _usernameController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatusController>();
    _usernameController.text = controller.name.value;
    _tagController.text = controller.tag.value;

    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("settings.data.change_name.dialog".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(sectionSpacing),
          LayoutBuilder(builder: (context, size) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: size.maxWidth * 0.6,
                  child: FJTextField(
                    hintText: 'placeholder.username'.tr,
                    controller: _usernameController,
                    maxLength: 16,
                  ),
                ),
                Text('#', style: Get.theme.textTheme.headlineMedium),
                SizedBox(
                  width: size.maxWidth * 0.3,
                  child: FJTextField(
                    hintText: 'placeholder.tag'.tr,
                    controller: _tagController,
                    maxLength: 5,
                  ),
                ),
              ],
            );
          }),
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
                "tag": _tagController.text,
              });

              if (!json["success"]) {
                _errorText.value = json["error"].toString().tr;
                _loading.value = false;
                return;
              }

              controller.name.value = _usernameController.text;
              controller.tag.value = _tagController.text;
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
