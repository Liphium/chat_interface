import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorWindow extends StatelessWidget {
  final String title;
  final String error;

  const ErrorWindow({super.key, required this.title, required this.error});

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      maxWidth: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Get.theme.textTheme.titleMedium),
          verticalSpacing(defaultSpacing),
          Text(error, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(sectionSpacing),
          FJElevatedButton(onTap: () => Get.back(), child: Center(child: Text("ok".tr, style: Get.theme.textTheme.titleMedium))),
        ],
      ),
    );
  }
}
