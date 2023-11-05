import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuccessContainer extends StatelessWidget {

  final String text;
  
  const SuccessContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(dialogPadding),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.background,
        borderRadius: BorderRadius.circular(dialogBorderRadius),
      ),
      child: Row(
        children: [
          Icon(Icons.check, color: Get.theme.colorScheme.secondary),
          horizontalSpacing(sectionSpacing),
          Text(text, style: Get.theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}