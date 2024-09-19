import 'dart:math';

import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_mobile.dart';
import 'package:chat_interface/pages/settings/settings_sidebar.dart';
import 'package:chat_interface/pages/settings/setting_selection_mobile.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageDesktop extends StatefulWidget {
  const SettingsPageDesktop({super.key});

  @override
  State<SettingsPageDesktop> createState() => _SettingsHomepageState();
}

class _SettingsHomepageState extends State<SettingsPageDesktop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      body: SafeArea(
        top: false,
        bottom: false,
        child: PlatformCallback(
          mobile: () {
            final current = Get.find<SettingController>().currentCategory.value;
            if (current != null) {
              Get.off(const SettingsPageMobile());
              Get.to(current.widget);
            } else {
              Get.off(const SettingsPageMobile());
            }
          },
          child: LayoutBuilder(builder: (context, constraints) {
            const sidebarWidth = 300.0;
            final biggestWidth = constraints.biggest.width;
            var containerWidth = 0.0;
            var pageWidth = 1000.0;
            if (biggestWidth > 1000 + sidebarWidth + 24) {
              containerWidth = (biggestWidth - 1000 - sidebarWidth) / 2;
            } else {
              pageWidth = biggestWidth - sidebarWidth - defaultSpacing * 1.5;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: containerWidth,
                ),
                Obx(
                  () {
                    final category = Get.find<SettingController>().currentCategory;
                    return SettingsSidebar(
                      sidebarWidth: sidebarWidth,
                      currentCategory: category.value?.label,
                      category: category,
                    );
                  },
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
                                    () {
                                      final category = Get.find<SettingController>().currentCategory;
                                      if (category.value != null && category.value!.displayTitle) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: defaultSpacing, bottom: sectionSpacing),
                                          child: Text(
                                            "settings.${category.value!.label}".tr,
                                            style: Get.theme.textTheme.headlineMedium,
                                          ),
                                        );
                                      }

                                      return const SizedBox();
                                    },
                                  ),
                                  Obx(
                                    () {
                                      final category = Get.find<SettingController>().currentCategory;
                                      if (category.value == null) {
                                        return SettingSelectionMobile(
                                          category: category,
                                          desktop: true,
                                        );
                                      }

                                      return category.value!.widget ?? const Placeholder();
                                    },
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
        ),
      ),
    );
  }
}
