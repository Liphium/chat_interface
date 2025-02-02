import 'package:chat_interface/theme/components/forms/icon_button.dart';
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
      elevation: 2.0,
      color: Get.theme.colorScheme.primaryContainer,
      child: DevicePadding(
        top: applyPadding,
        right: true,
        left: true,
        padding: const EdgeInsets.symmetric(
          vertical: elementSpacing,
          horizontal: defaultSpacing,
        ),
        child: Row(
          children: [
            LoadingIconButton(
              onTap: () => Get.back(),
              iconSize: fittedIconSize(24),
              icon: Icons.arrow_back,
              color: Get.theme.colorScheme.onPrimary,
            ),
            horizontalSpacing(defaultSpacing),
            Text(
              label.tr,
              style: Get.theme.textTheme.labelLarge,
            )
          ],
        ),
      ),
    );
  }
}
