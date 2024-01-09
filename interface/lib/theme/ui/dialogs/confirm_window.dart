import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmWindow extends StatelessWidget {

  /// Requires translation
  final String title;
  /// Requires translation 
  final String text;
  final Function() onConfirm;
  final Function() onDecline;

  const ConfirmWindow({super.key, required this.title, required this.text, required this.onConfirm, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Get.theme.textTheme.titleMedium),
          verticalSpacing(defaultSpacing),
          Text(text, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(sectionSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FJElevatedButton(
                  onTap: () {
                    Get.back();
                    onConfirm();
                  }, 
                  child: Center(child: Text("yes".tr, style: Get.theme.textTheme.titleMedium),)
                ),
              ),
              horizontalSpacing(defaultSpacing),
              Expanded(
                child: FJElevatedButton(
                  onTap: () {
                    Get.back();
                    onDecline();
                  }, 
                  child: Center(child: Text("no".tr, style: Get.theme.textTheme.titleMedium),)
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}