import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableItem {
  final String label;
  final IconData icon;
  final bool experimental;

  const SelectableItem(this.label, this.icon, {this.experimental = false});
}

class ListSelectionSetting extends StatefulWidget {
  final String settingName;
  final List<SelectableItem> items;
  final Function(SelectableItem)? callback;

  const ListSelectionSetting({super.key, required this.settingName, required this.items, this.callback});

  @override
  State<ListSelectionSetting> createState() => _ListSelectionSettingState();
}

class _ListSelectionSettingState extends State<ListSelectionSetting> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.items.length, (index) {
        final first = index == 0;
        final last = index == widget.items.length - 1;

        final radius = BorderRadius.vertical(
          top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
          bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
          child: Obx(
            () => Material(
              color: SettingController.settings[widget.settingName]!.getWhenValue(0, 0) == index
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.onInverseSurface,
              borderRadius: radius,
              child: InkWell(
                borderRadius: radius,
                onTap: () {
                  SettingController.settings[widget.settingName]!.setValue(index);
                  if (widget.callback != null) {
                    widget.callback!(widget.items[index]);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(defaultSpacing),
                  child: Row(
                    children: [
                      Icon(widget.items[index].icon, color: Get.theme.colorScheme.onPrimary),
                      horizontalSpacing(defaultSpacing),
                      Flexible(
                        child: Text(
                          widget.items[index].label.tr,
                          style: Get.theme.textTheme.bodyMedium!.copyWith(color: Get.theme.colorScheme.onSurface),
                        ),
                      ),
                      horizontalSpacing(defaultSpacing),
                      if (widget.items[index].experimental)
                        LayoutBuilder(builder: (context, constraints) {
                          if (isMobileMode()) {
                            return Tooltip(
                              message: "settings.experimental".tr,
                              child: Icon(Icons.science, color: Get.theme.colorScheme.error),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(defaultSpacing),
                            ),
                            padding: const EdgeInsets.all(elementSpacing),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.science, color: Get.theme.colorScheme.error),
                                horizontalSpacing(elementSpacing),
                                Flexible(
                                  child: Text(
                                    "settings.experimental".tr,
                                    style: Get.theme.textTheme.bodyMedium!.copyWith(color: Get.theme.colorScheme.error),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                                horizontalSpacing(elementSpacing)
                              ],
                            ),
                          );
                        })
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
