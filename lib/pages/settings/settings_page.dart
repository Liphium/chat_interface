import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final currentCategory = SettingLabel.values[0].categories[0].obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: ListView.builder(
                itemCount: SettingLabel.values.length+1,
                itemBuilder: (context, index) {
                  if(index == 0) {
                    return ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back),
                          horizontalSpacing(defaultSpacing * 0.5),
                          Text("back".tr, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      )
                    );
                  }

                  final current = SettingLabel.values[index-1];

                  return Padding(
                    padding: const EdgeInsets.only(top: defaultSpacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(current.label, style: Theme.of(context).textTheme.titleMedium),
                        verticalSpacing(defaultSpacing * 0.5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: current.categories.map((element) => 
                            Padding(
                              padding: const EdgeInsets.only(top: defaultSpacing * 0.5),
                              child: Obx(() => Material(
                                color: currentCategory.value == element ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                child: InkWell(
                                  onTap: () => currentCategory.value = element,
                                  borderRadius: BorderRadius.circular(defaultSpacing),
                                  child: Padding(
                                    padding: const EdgeInsets.all(defaultSpacing * 0.5),
                                    child: Row(
                                      children: [
                                        Icon(
                                          element.icon,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        horizontalSpacing(defaultSpacing * 0.5),
                                        Text(element.label, style: Theme.of(context).textTheme.bodyMedium),
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
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: Obx(() => currentCategory.value.widget ?? const Placeholder()),
              ),
            ),
          ),
        ],
      )
    );
  }
}