import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ChangeDisplayNameWindow extends StatefulWidget {
  const ChangeDisplayNameWindow({super.key});

  @override
  State<ChangeDisplayNameWindow> createState() => _ChangeNameWindowState();
}

class _ChangeNameWindowState extends State<ChangeDisplayNameWindow> {
  // Text controllers
  final _displayNameController = TextEditingController();

  // State
  final _errorText = signal('');
  final _loading = signal(false);

  @override
  void dispose() {
    _errorText.dispose();
    _loading.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  /// Save the display name
  Future<void> save() async {
    if (_loading.value) return;
    _loading.value = true;
    _errorText.value = "";

    final json = await postAuthorizedJSON("/account/settings/change_display_name", {"name": _displayNameController.text});

    if (!json["success"]) {
      _errorText.value = json["error"].toString().tr;
      _loading.value = false;
      return;
    }

    StatusController.displayName.value = _displayNameController.text;
    _loading.value = false;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    _displayNameController.text = StatusController.displayName.value;

    return DialogBase(
      title: [Text("display_name".tr, style: Get.textTheme.labelLarge)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("display_name.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          FJTextField(
            hintText: 'placeholder.display_name'.tr,
            controller: _displayNameController,
            maxLength: 16,
            autofocus: true,
            onSubmitted: (t) => save(),
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(message: _errorText, padding: const EdgeInsets.only(bottom: defaultSpacing), expand: true),
          FJElevatedLoadingButtonCustom(
            loading: _loading,
            onTap: () => save(),
            child: Center(child: Text("save".tr, style: Get.theme.textTheme.labelLarge)),
          ),
        ],
      ),
    );
  }
}
