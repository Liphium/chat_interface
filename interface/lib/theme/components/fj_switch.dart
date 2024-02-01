import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FJSwitch extends StatelessWidget {
  final bool value;
  final Function(bool)? onChanged;
  final bool secondary;

  const FJSwitch(
      {super.key, required this.value, this.onChanged, this.secondary = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 33,
      width: 54,
      child: Switch(
        trackColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.primaryContainer),
        hoverColor: Get.theme.hoverColor,
        thumbColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Get.theme.colorScheme.onPrimary
                : Get.theme.colorScheme.surface),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
