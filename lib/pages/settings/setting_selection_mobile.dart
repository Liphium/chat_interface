import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SettingSelectionMobile extends StatelessWidget {
  final Signal<SettingCategory?>? category;
  final bool desktop;

  const SettingSelectionMobile({super.key, this.desktop = false, this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(SettingLabel.values.length, (index) {
        final current = SettingLabel.values[index];

        //* Sidebar buttons
        return Padding(
          padding: EdgeInsets.only(
            top: index == 0 && Get.mediaQuery.padding.top == 0 ? defaultSpacing : 0,
            bottom: index == SettingLabel.values.length - 1 ? defaultSpacing : sectionSpacing * 2,
            left: defaultSpacing * 1.5,
            right: defaultSpacing * 1.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: desktop ? 0 : elementSpacing),
                child: Text(current.label.tr, style: Theme.of(context).textTheme.headlineMedium),
              ),
              verticalSpacing(defaultSpacing * 0.5),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:
                    current.categories.map((element) {
                      if (!element.mobile && GetPlatform.isMobile) {
                        return const SizedBox();
                      }
                      if (!element.web && isWeb) {
                        return const SizedBox();
                      }
                      if (!StatusController.permissions.contains("admin") && element.admin) {
                        return const SizedBox();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: defaultSpacing),
                        child: Material(
                          color: Get.theme.colorScheme.inverseSurface,
                          borderRadius: BorderRadius.circular(sectionSpacing),
                          child: InkWell(
                            onTap: () {
                              if (category == null) {
                                Get.to(element.widget);
                              } else {
                                category!.value = element;
                              }
                            },
                            borderRadius: BorderRadius.circular(sectionSpacing),
                            child: Padding(
                              padding: const EdgeInsets.all(defaultSpacing),
                              child: Row(
                                children: [
                                  Icon(
                                    element.icon,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    size: Get.theme.textTheme.titleLarge!.fontSize! * 2,
                                  ),
                                  horizontalSpacing(defaultSpacing),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "settings.${element.label}".tr,
                                          style: Theme.of(context).textTheme.labelLarge!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "settings.${element.label}.desc".tr,
                                          style: Theme.of(context).textTheme.bodyMedium!,
                                        ),
                                      ],
                                    ),
                                  ),
                                  horizontalSpacing(defaultSpacing),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: Get.theme.textTheme.titleLarge!.fontSize! * 1.5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
