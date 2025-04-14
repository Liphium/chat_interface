import 'dart:io';

import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class WarpCreateWindow extends StatefulWidget {
  const WarpCreateWindow({super.key});

  @override
  State<WarpCreateWindow> createState() => _WarpCreateWindowState();
}

class _WarpCreateWindowState extends State<WarpCreateWindow> {
  // Controller for the port input
  final TextEditingController _port = TextEditingController();

  // State
  final _error = signal("");
  final _loading = signal(false);

  @override
  void dispose() {
    _port.dispose();
    _error.dispose();
    _loading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Text("warp.create.title".tr, style: Get.textTheme.labelLarge)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "warp.create.desc".tr,
            style: Get.theme.textTheme.bodyMedium,
            textAlign: TextAlign.start,
          ),
          verticalSpacing(defaultSpacing),
          FJTextField(
            maxLength: 5,
            controller: _port,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            hintText: 'warp.port.placeholder'.tr,
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            message: _error,
          ),
          FJElevatedLoadingButton(
            onTap: () async {
              _loading.value = true;
              _error.value = "";

              // Convert the port to an actual port number
              final port = int.tryParse(_port.text);
              if (port == null || port < 1024 || port > 65535) {
                _loading.value = false;
                _error.value = "warp.error.port_invalid".tr;
                return;
              }

              // Try connecting to the port to make sure there is a server there
              try {
                await Socket.connect("localhost", port);
              } catch (e) {
                _loading.value = false;
                _error.value = "warp.error.port_not_used".tr;
                return;
              }

              // Create the warp on the server
              final error = await WarpController.createWarp(port);
              _loading.value = false;
              _error.value = error ?? "";
              if (error == null) {
                Get.back();
              }
            },
            label: 'warp.create.button'.tr,
            loading: _loading,
          ),
        ],
      ),
    );
  }
}
