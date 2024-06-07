import 'dart:math';

import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/settings_sidebar.dart';
import 'package:chat_interface/pages/settings/setting_selection_mobile.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

class SettingsDesktopFrame extends StatefulWidget {
  const SettingsDesktopFrame({super.key});

  @override
  State<SettingsDesktopFrame> createState() => _SettingsHomepageState();
}

class _SettingsHomepageState extends State<SettingsDesktopFrame> {
  final currentCategory = Rx<SettingCategory?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      body: LayoutBuilder(builder: (context, constraints) {
        const sidebarWidth = 250.0;
        final biggestWidth = constraints.biggest.width;
        var containerWidth = 0.0;
        var pageWidth = 1000.0;
        if (biggestWidth > 1000 + sidebarWidth + 24) {
          containerWidth = (biggestWidth - 1000 - sidebarWidth) / 2;
        } else {
          pageWidth = biggestWidth - sidebarWidth - 8;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: containerWidth,
            ),
            Obx(
              () => SettingsSidebar(
                sidebarWidth: sidebarWidth,
                currentCategory: currentCategory.value?.label,
                category: currentCategory,
              ),
            ),

            //* Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: defaultSpacing),
                child: SingleChildScrollView(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: pageWidth),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing, right: defaultSpacing),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => currentCategory.value != null && currentCategory.value!.displayTitle
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: defaultSpacing, bottom: sectionSpacing),
                                        child: Text(
                                          "settings.${currentCategory.value!.label}".tr,
                                          style: Get.theme.textTheme.headlineMedium,
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                              Obx(
                                () => currentCategory.value == null
                                    ? SidebarMobile(
                                        category: currentCategory,
                                        desktop: true,
                                      )
                                    : currentCategory.value!.widget ?? const Placeholder(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: max(containerWidth, 8) - 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
