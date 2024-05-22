import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/theme/ui/containers/universal_app_bar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: SafeArea(
        child: Column(
          children: [
            UniversalAppBar(label: "app.settings".tr),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: SettingLabel.values.length,
                  itemBuilder: (context, index) {
                    final current = SettingLabel.values[index];

                    //* Sidebar buttons
                    return Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? defaultSpacing : 0,
                        bottom: index == SettingLabel.values.length - 1 ? defaultSpacing : sectionSpacing * 2,
                        left: defaultSpacing,
                        right: defaultSpacing,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
                            child: Text(
                              current.label.tr,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          verticalSpacing(defaultSpacing * 0.5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: current.categories
                                .map(
                                  (element) => Padding(
                                    padding: const EdgeInsets.only(top: defaultSpacing),
                                    child: Material(
                                      color: Get.theme.colorScheme.inverseSurface,
                                      borderRadius: BorderRadius.circular(sectionSpacing),
                                      child: InkWell(
                                        onTap: () => {},
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
                                                      overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
}
