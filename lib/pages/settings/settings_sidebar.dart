import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsSidebar extends StatelessWidget {
  final Rx<SettingCategory?>? category;
  final String? currentCategory;
  final double sidebarWidth;

  const SettingsSidebar({super.key, required this.sidebarWidth, this.currentCategory, this.category});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: sidebarWidth),
      child: Padding(
        padding: GetPlatform.isMobile && !isMobileMode() ? const EdgeInsets.only(left: defaultSpacing) : const EdgeInsets.all(defaultSpacing),
        child: ListView.builder(
          itemCount: SettingLabel.values.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return FJElevatedButton(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(defaultSpacing * 0.5),
                    Text("back".tr, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Get.theme.colorScheme.onSurface)),
                  ],
                ),
              );
            }

            final current = SettingLabel.values[index - 1];

            //* Sidebar buttons
            return Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  verticalSpacing(sectionSpacing),
                  Text(current.label.tr, style: Theme.of(context).textTheme.titleLarge),
                  verticalSpacing(defaultSpacing * 0.5),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: current.categories
                        .map(
                          (element) => Padding(
                            padding: const EdgeInsets.only(top: defaultSpacing),
                            child: Material(
                              color: currentCategory == element.label ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              child: InkWell(
                                onTap: () {
                                  if (category != null) {
                                    category!.value = element;
                                  } else {
                                    Get.to(
                                      element.widget,
                                      transition: Transition.fadeIn,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                child: Padding(
                                  padding: const EdgeInsets.all(defaultSpacing),
                                  child: Row(
                                    children: [
                                      Icon(
                                        element.icon,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        size: Get.theme.textTheme.titleLarge!.fontSize! * 1.5,
                                      ),
                                      horizontalSpacing(defaultSpacing),
                                      Expanded(
                                        child: Text(
                                          "settings.${element.label}".tr,
                                          style: Theme.of(context).textTheme.labelLarge!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
