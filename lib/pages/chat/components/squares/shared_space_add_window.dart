import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SharedSpaceAddWindow extends StatefulWidget {
  final Square square;
  final String? action;
  final SharedSpace? space;
  final PinnedSharedSpace? pinned;
  final bool onlyEdit;

  const SharedSpaceAddWindow({
    super.key,
    required this.square,
    this.action = "create",
    this.space,
    this.pinned,
    this.onlyEdit = false,
  });

  @override
  State<SharedSpaceAddWindow> createState() => _SharedSpaceAddWindowState();
}

class _SharedSpaceAddWindowState extends State<SharedSpaceAddWindow> {
  // Text controllers
  final _nameController = TextEditingController();

  // The current pin state
  late final _pinned = signal(widget.pinned != null);

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

    // Edit the space in case in edit mode
    if (widget.onlyEdit) {
      await editSpace(name);
      return;
    }

    // Create a pinned space in case desired
    if (_pinned.peek()) {
      // Pin the space
      final pinnedSpace = SquareService.newPinnedSharedSpace(widget.square, name);
      var error = await SquareService.pinPinnedSpace(widget.square, pinnedSpace);
      if (error != null) {
        _errorText.value = error;
        _loading.value = false;
        return;
      }

      // Create a new shared space with the pinned space passed in
      error = await SquareService.createSharedSpace(widget.square, name, underlyingId: pinnedSpace.id, rejoin: true);
      if (error != null) {
        _errorText.value = error;
        _loading.value = false;
        return;
      }

      _loading.value = false;
      Get.back();
      return;
    }

    // Create the Space
    final error = await SquareService.createSharedSpace(widget.square, name, rejoin: true);
    if (error != null) {
      _errorText.value = error;
      _loading.value = false;
      return;
    }

    _loading.value = false;
    Get.back();
  }

  /// Edit the space
  Future<void> editSpace(String name) async {
    // If the space shouldn't be pinned anymore, unpin it
    if (widget.pinned != null && !_pinned.peek()) {
      sendLog("unpin shared space");
      // If it shouldn't be pinned anymore, remove it
      final error = await SquareService.unpinSharedSpace(widget.square, widget.pinned!.id, space: widget.space);
      if (error != null) {
        _errorText.value = error;
        _loading.value = false;
        return;
      }
    }

    // If the space should be pinned, pin it
    if (widget.pinned == null && widget.space != null && _pinned.peek()) {
      sendLog("pin shared space");
      final error = await SquareService.pinSharedSpace(widget.square, widget.space!);
      if (error != null) {
        _errorText.value = error;
        _loading.value = false;
        return;
      }
    }

    // If the name changed and there is a pinned spxace, change the name of it
    if (name != (widget.pinned?.name ?? "") && widget.pinned != null && _pinned.peek()) {
      sendLog("change name square");
      final error = await SquareService.changePinnedName(widget.square, widget.pinned!, name);
      if (error != null) {
        _errorText.value = error;
        _loading.value = false;
        return;
      }
    }

    // If there is a shared space, also change the name on the server
    if (name != (widget.space?.name ?? "") && widget.space != null) {
      sendLog("change name shared-spaces");
      final error = await SquareService.renameSharedSpace(widget.square, widget.space!.id, name);
      if (error != null) {
        _errorText.value = error;
        _loading.value = false;
        return;
      }
    }

    _loading.value = false;
    Get.back();
  }

  @override
  void initState() {
    // Set the name in case provided
    if (widget.pinned != null) {
      _nameController.text = widget.pinned!.name;
    }
    if (widget.space != null) {
      _nameController.text = widget.space!.name;
    }
    super.initState();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("pinned".tr, style: Get.theme.textTheme.bodyMedium),
              Watch(
                (ctx) => FJSwitch(
                  value: _pinned.value,
                  onChanged: (p0) {
                    _pinned.value = p0;
                  },
                ),
              ),
            ],
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
