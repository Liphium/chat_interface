import 'package:chat_interface/theme/ui/containers/universal_app_bar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageBase extends StatelessWidget {
  final String label;
  final Widget child;

  const SettingsPageBase({super.key, required this.child, required this.label});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Use mobile version on mobile
      if (!isMobileMode()) {
        return child;
      }

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        body: Column(
          children: [
            UniversalAppBar(label: "settings.$label".tr),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: sectionSpacing),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing, right: sectionSpacing),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
