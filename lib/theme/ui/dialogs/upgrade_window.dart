import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpgradeWindow extends StatelessWidget {
  const UpgradeWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upgrade to a better Liphium.",
            style: Get.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          verticalSpacing(sectionSpacing),
          Text(
            "Liphium Web has a lot of limitations. If you want a better experience, Liphium is available as a native app on all major platforms.",
            style: Get.textTheme.bodyMedium,
          ),
          verticalSpacing(defaultSpacing),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.inverseSurface,
            ),
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              children: [
                Icon(Icons.speed, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("Native-level performance", style: Get.textTheme.labelMedium),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.inverseSurface,
            ),
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              children: [
                Icon(Icons.electric_bolt, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("Zap for sharing the biggest files", style: Get.textTheme.labelMedium),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.inverseSurface,
            ),
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              children: [
                Icon(Icons.rocket_launch, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("Spaces for having a good time", style: Get.textTheme.labelMedium),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(defaultSpacing),
              color: Get.theme.colorScheme.inverseSurface,
            ),
            padding: const EdgeInsets.all(defaultSpacing),
            child: Row(
              children: [
                Icon(Icons.cloud, color: Get.theme.colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text("Sharing files with your friends", style: Get.textTheme.labelMedium),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () => launchUrlString("https://liphium.com/"),
            child: Center(
              child: Text("Visit the website", style: Get.textTheme.labelLarge),
            ),
          ),
        ],
      ),
    );
  }
}
