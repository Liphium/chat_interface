import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoubleSelectionSetting extends StatefulWidget {
  
  final String settingName;
  final String description;
  final double min;
  final double max;
 
  const DoubleSelectionSetting({super.key, required this.settingName, required this.description, required this.min, required this.max});

  @override
  State<DoubleSelectionSetting> createState() => _ListSelectionSettingState();
}

class _ListSelectionSettingState extends State<DoubleSelectionSetting> {

  // Current value
  final current = 0.0.obs;

  @override
  Widget build(BuildContext context) {

    SettingController controller = Get.find();
    final setting = controller.settings[widget.settingName]!;
    current.value = setting.getValue() as double;

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.description.tr, style: Get.theme.textTheme.bodyMedium),
          Obx(() =>
            Slider(
              value: clampDouble(current.value, widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              inactiveColor: Get.theme.colorScheme.onBackground,
              thumbColor: Get.theme.colorScheme.onPrimary,
              activeColor: Get.theme.colorScheme.onPrimary,
              secondaryActiveColor: Get.theme.colorScheme.secondary,
              onChanged: (value) => current.value = value,
              onChangeEnd: (value) {
                setting.setValue(value);
              },
            )
          ),
        ],
      ),
    );
  }
}