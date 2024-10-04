import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LPHCopyField extends StatelessWidget {
  final String label;
  final String value;

  const LPHCopyField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(defaultSpacing),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.labelSmall,
                ),
                Tooltip(
                  waitDuration: const Duration(milliseconds: 500),
                  exitDuration: const Duration(microseconds: 0),
                  message: "$label: $value",
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          IconButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: value)),
            icon: Icon(Icons.copy, color: Get.theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

class LPHActionData {
  final IconData icon;
  final String tooltip;
  final Function() onClick;

  LPHActionData({required this.icon, required this.tooltip, required this.onClick});
}

class LPHActionField extends StatelessWidget {
  final String primary;
  final String secondary;
  final List<LPHActionData> actions;

  const LPHActionField({
    super.key,
    required this.primary,
    required this.secondary,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultSpacing),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(defaultSpacing),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  overflow: TextOverflow.ellipsis,
                  style: Get.textTheme.labelSmall,
                ),
                Tooltip(
                  waitDuration: const Duration(milliseconds: 500),
                  exitDuration: const Duration(microseconds: 0),
                  message: "$primary: $secondary",
                  child: Text(
                    secondary,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          horizontalSpacing(elementSpacing),
          for (var action in actions)
            Padding(
              padding: const EdgeInsets.only(right: elementSpacing),
              child: IconButton(
                tooltip: action.tooltip,
                onPressed: action.onClick,
                icon: Icon(action.icon, color: Get.theme.colorScheme.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
