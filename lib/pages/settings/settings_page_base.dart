import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_desktop.dart';
import 'package:chat_interface/theme/ui/containers/universal_app_bar.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageBase extends StatelessWidget {
  final String label;
  final Widget child;

  const SettingsPageBase({
    super.key,
    required this.child,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMobileMode()) {
      return child;
    }

    return PlatformCallback(
      mobile: () {
        sendLog("switch to mobile");
      },
      desktop: () {
        sendLog("switch to desktop ($label)");
        Get.back();
        Get.off(const SettingsPageDesktop());
        for (var settingLabel in SettingLabel.values) {
          final category = settingLabel.categories.firstWhereOrNull((e) => e.label == label);
          if (category != null) {
            SettingController.currentCategory.value = category;
            break;
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        body: Column(
          children: [
            UniversalAppBar(
              label: "settings.$label".tr,
              applyPadding: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: sectionSpacing),
                child: SingleChildScrollView(
                  child: SafeArea(
                    bottom: true,
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: defaultSpacing,
                            bottom: defaultSpacing,
                            right: sectionSpacing,
                          ),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
