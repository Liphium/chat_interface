import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/snackbar.dart';
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
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Padding(
                  padding: const EdgeInsets.all(defaultSpacing),
                  child: ListView.builder(
                    itemCount: SettingLabel.values.length+1,
                    itemBuilder: (context, index) {
                      if(index == 0) {
                        return FJElevatedButton(
                          onTap: () => Get.back(),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
                              horizontalSpacing(defaultSpacing * 0.5),
                              Text("back".tr, style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.onSurface
                              )),
                            ],
                          )
                        );
                      }

                      final current = SettingLabel.values[index-1];

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
                              children: current.categories.map((element) => 
                                Padding(
                                  padding: const EdgeInsets.only(top: defaultSpacing),
                                  child: Obx(() => Material(
                                    color: currentCategory.value == element ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(defaultSpacing),
                                    child: InkWell(
                                      onTap: () => currentCategory.value = element,
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
                                            horizontalSpacing(defaultSpacing * 0.5),
                                            Text("settings.${element.label}".tr, style: Theme.of(context).textTheme.labelLarge!),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                                )
                              ).toList(),
                            )
                          ] 
                        )
                      );
                    },
                  ),
                )
              ),

              //* Content
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() =>
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.5),
                                child: Text("settings.${currentCategory.value.label}".tr, style: theme.textTheme.headlineMedium),
                              )
                            ),
                            verticalSpacing(elementSpacing),
                            Obx(() => currentCategory.value.widget ?? const Placeholder()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const NotificationRenderer(position: Offset(20, 20))
        ],
      )
    );
  }
}