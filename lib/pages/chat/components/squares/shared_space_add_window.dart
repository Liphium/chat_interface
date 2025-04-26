import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SharedSpaceAddWindow extends StatefulWidget {
  final Square square;
  final String? action;

  const SharedSpaceAddWindow({super.key, required this.square, this.action = "create"});

  @override
  State<SharedSpaceAddWindow> createState() => _SharedSpaceAddWindowState();
}

class _SharedSpaceAddWindowState extends State<SharedSpaceAddWindow> {
  // Text controllers
  final _nameController = TextEditingController();

  // State
  final _errorText = signal('');
  final _loading = signal(false);

  @override
  void dispose() {
    _errorText.dispose();
    _loading.dispose();
    super.dispose();
  }

  /// Perform the action
  Future<void> save() async {
    if (_loading.value) return;
    _loading.value = true;
    _errorText.value = "";

    // Make sure the name fits within the requirements
    final name = _nameController.text;
    if (name.isEmpty || name == "") {
      _errorText.value = "squares.space.name_needed".tr;
      _loading.value = false;
      return;
    }
    if (name.length > specialConstants[Constants.specialConstantMaxConversationNameLength]!) {
      _errorText.value = "squares.space.name.length".trParams({
        "length": specialConstants[Constants.specialConstantMaxConversationNameLength].toString(),
      });
      _loading.value = false;
      return;
    }

    // Attach the space
    final error = await SquareService.createSharedSpace(widget.square, name);
    if (error != null) {
      _errorText.value = error;
      _loading.value = false;
      return;
    }

    _loading.value = false;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("squares.spaces.${widget.action}".tr, style: Get.textTheme.labelLarge)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FJTextField(
            hintText: 'squares.spaces.name.placeholder'.tr,
            controller: _nameController,
            maxLength: specialConstants[Constants.specialConstantMaxConversationNameLength],
            autofocus: true,
            onSubmitted: (t) => save(),
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            message: _errorText,
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            expand: true,
          ),
          FJElevatedLoadingButtonCustom(
            loading: _loading,
            onTap: () => save(),
            child: Center(child: Text("${widget.action}".tr, style: Get.theme.textTheme.labelLarge)),
          ),
        ],
      ),
    );
  }
}
