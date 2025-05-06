import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class BoolSettingSmall extends StatelessWidget {
  final String settingName;
  final Function(bool)? onChanged;

  const BoolSettingSmall({super.key, required this.settingName, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Watch(
      (ctx) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: Text(settingName.tr, style: Get.theme.textTheme.bodyMedium)),
          horizontalSpacing(defaultSpacing),
          Switch(
            activeColor: Get.theme.colorScheme.secondary,
            trackColor: WidgetStateColor.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected)
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.onInverseSurface,
            ),
            hoverColor: Get.theme.hoverColor,
            thumbColor: WidgetStateColor.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected)
                      ? Get.theme.colorScheme.onPrimary
                      : Get.theme.colorScheme.surface,
            ),
            value: SettingController.settings[settingName]!.getValue(),
            onChanged: (value) {
              SettingController.settings[settingName]!.setValue(value);
              onChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
