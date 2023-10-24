import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableItem {
  final String label;
  final IconData icon;

  const SelectableItem(this.label, this.icon);
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

    SettingController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing * 0.5),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.items.length,
        itemBuilder: (context, index) {

          final first = index == 0;
          final last = index == widget.items.length - 1;
          
          final radius = BorderRadius.vertical(
            top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
            bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
            child: Obx(() => 
              Material(
                color: controller.settings[widget.settingName]!.getWhenValue(0, 0) == index ? Get.theme.colorScheme.primary :
                  Get.theme.colorScheme.onBackground,
                borderRadius: radius,
                child: InkWell(
                  borderRadius: radius,
                  onTap: () {
                    controller.settings[widget.settingName]!.setValue(index);
                    if(widget.callback != null) {
                      widget.callback!(widget.items[index]);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(defaultSpacing),
                    child: Row(
                      children: [
                        Icon(widget.items[index].icon, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(defaultSpacing),
                        Text(widget.items[index].label.tr, style: Get.theme.textTheme.bodyMedium!.copyWith(
                          color: Get.theme.colorScheme.onSurface
                        )),
                      ],
                    ),
                  ),
                ),
              )
            ),
          );
        },
      ),
    );
  }
}