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
        color: Get.theme.colorScheme.primaryContainer,
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
