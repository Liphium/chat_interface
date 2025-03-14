import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_slider.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class DoubleSelectionSetting extends StatefulWidget {
  final String settingName;

  /// Translated automatically
  final String description;
  final double min;
  final double max;
  final bool rounded;
  final String unit;
  final Function(double)? onChange;

  const DoubleSelectionSetting({
    super.key,
    required this.settingName,
    required this.description,
    required this.min,
    required this.max,
    this.unit = "",
    this.rounded = false,
    this.onChange,
  });

  @override
  State<DoubleSelectionSetting> createState() => _ListSelectionSettingState();
}

class _ListSelectionSettingState extends State<DoubleSelectionSetting> {
  // Current value
  final _current = signal(0.0);

  @override
  void dispose() {
    _current.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setting = SettingController.settings[widget.settingName]!;
    _current.value = setting.getValue() as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
            visible: widget.description.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(bottom: elementSpacing),
              child: Text(widget.description.tr, style: Get.theme.textTheme.bodyMedium),
            )),
        Watch((ctx) {
          final value = _current.value;
          final roundedCurrent = widget.rounded ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FJSlider(
                  value: clampDouble(value, widget.min, widget.max),
                  min: widget.min,
                  max: widget.max,
                  onChanged: (value) {
                    if (widget.rounded) {
                      _current.value = value.roundToDouble();
                    } else {
                      _current.value = value;
                    }
                    widget.onChange?.call(_current.value);
                  },
                  onChangeEnd: (value) {
                    if (widget.rounded) {
                      setting.setValue(value.roundToDouble());
                    } else {
                      setting.setValue(value);
                    }
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
