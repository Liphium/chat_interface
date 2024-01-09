import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/components/fj_slider.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoubleSelectionSetting extends StatefulWidget {
  
  final String settingName;
  /// Translated automatically
  final String description;
  final double min;
  final double max;
  final String unit;
 
  const DoubleSelectionSetting({super.key, required this.settingName, required this.description, required this.min, required this.max, this.unit = ""});

  @override
  State<DoubleSelectionSetting> createState() => _ListSelectionSettingState();
}

class _ListSelectionSettingState extends State<DoubleSelectionSetting> {

  // Current value
  final current = 0.0.obs;
  DateTime? lastSet;

  @override
  Widget build(BuildContext context) {

    SettingController controller = Get.find();
    final setting = controller.settings[widget.settingName]!;
    current.value = setting.getValue() as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.description.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.only(bottom: elementSpacing),
            child: Text(widget.description.tr, style: Get.theme.textTheme.bodyMedium),
          )
        ),
        Obx(() {
          final value = current.value;
          final roundedCurrent = value.toStringAsFixed(1);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FJSlider(
                  value: clampDouble(value, widget.min, widget.max),
                  min: widget.min,
                  max: widget.max,
                  onChanged: (value) {
                    current.value = value;
                    if(DateTime.now().difference(lastSet ?? DateTime.now()).inMilliseconds > 100) {
                      lastSet = DateTime.now();
                      setting.setValue(value);
                    }
                  },
                  onChangeEnd: (value) {
                    setting.setValue(value);
                  },
                ),
              ),
              horizontalSpacing(defaultSpacing),
              Text("$roundedCurrent ${widget.unit.tr}", style: Get.theme.textTheme.bodyMedium),
            ],
          );
        }),
      ],
    );
  }
}