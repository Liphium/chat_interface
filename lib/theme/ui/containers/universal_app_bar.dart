import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UniversalAppBar extends StatelessWidget {
  /// Automatically translated
  final String label;
  final bool applyPadding;

  const UniversalAppBar({
    super.key,
    required this.label,
    this.applyPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.primaryContainer,
      child: SafeArea(
        top: applyPadding,
        bottom: false,
        right: true,
        left: true,
        child: Padding(
          padding: GetPlatform.isMobile
              ? const EdgeInsets.only(
                  bottom: defaultSpacing,
                  right: defaultSpacing,
                  left: defaultSpacing,
                )
              : const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back,
                  color: Get.theme.colorScheme.onPrimary,
                ),
              ),
              horizontalSpacing(defaultSpacing),
              Text(
                label.tr,
                style: Get.theme.textTheme.labelLarge,
              )
            ],
          ),
        ),
      ),
    );
  }
}
