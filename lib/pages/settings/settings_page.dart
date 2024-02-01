import 'dart:math';

import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeData theme = Get.theme;
  final currentCategory = SettingLabel.values[0].categories[0].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: sidebarWidth),
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: ListView.builder(
                  itemCount: SettingLabel.values.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return FJElevatedButton(
                        onTap: () => Get.back(),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back,
                                color: theme.colorScheme.onPrimary),
                            horizontalSpacing(defaultSpacing * 0.5),
                            Text("back".tr,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: theme.colorScheme.onSurface)),
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
                          Text(current.label.tr,
                              style: Theme.of(context).textTheme.titleLarge),
                          verticalSpacing(defaultSpacing * 0.5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: current.categories
                                .map(
                                  (element) => Padding(
                                    padding: const EdgeInsets.only(
                                        top: defaultSpacing),
                                    child: Obx(
                                      () => Material(
                                        color: currentCategory.value == element
                                            ? Get.theme.colorScheme.primary
                                            : Get.theme.colorScheme
                                                .primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            defaultSpacing),
                                        child: InkWell(
                                          onTap: () =>
                                              currentCategory.value = element,
                                          borderRadius: BorderRadius.circular(
                                              defaultSpacing),
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                defaultSpacing),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  element.icon,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  size: Get
                                                          .theme
                                                          .textTheme
                                                          .titleLarge!
                                                          .fontSize! *
                                                      1.5,
                                                ),
                                                horizontalSpacing(
                                                    defaultSpacing),
                                                Expanded(
                                                  child: Text(
                                                    "settings.${element.label}"
                                                        .tr,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                          padding: const EdgeInsets.only(
                              bottom: defaultSpacing, right: defaultSpacing),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => currentCategory.value.displayTitle
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: defaultSpacing,
                                            bottom: sectionSpacing),
                                        child: Text(
                                            "settings.${currentCategory.value.label}"
                                                .tr,
                                            style:
                                                theme.textTheme.headlineMedium),
                                      )
                                    : const SizedBox(),
                              ),
                              Obx(() =>
                                  currentCategory.value.widget ??
                                  const Placeholder()),
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
