import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BoolSettingSmall extends StatelessWidget {
  final String settingName;
  final Function(bool)? onChanged;

  const BoolSettingSmall({super.key, required this.settingName, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingController>();
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(settingName.tr, style: Get.theme.textTheme.bodyMedium),
          Switch(
            activeColor: Get.theme.colorScheme.secondary,
            trackColor:
                MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Get.theme.colorScheme.primary : Get.theme.colorScheme.onBackground),
            hoverColor: Get.theme.hoverColor,
            thumbColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.surface),
            value: controller.settings[settingName]!.getValue(),
            onChanged: (value) {
              controller.settings[settingName]!.setValue(value);
              onChanged?.call(value);
            },
          )
        ],
      ),
    );
  }
}
