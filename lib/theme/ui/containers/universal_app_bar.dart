import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UniversalAppBar extends StatelessWidget {
  /// Automatically translated
  final String label;

  const UniversalAppBar({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(defaultSpacing),
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
    );
  }
}
