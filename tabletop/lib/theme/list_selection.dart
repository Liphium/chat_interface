import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectableItem {
  final String label;
  final IconData icon;
  final Color? iconColor;

  const SelectableItem(this.label, this.icon, {this.iconColor});
}

class ListSelection extends StatelessWidget {
  
  final int currentIndex;
  final List<SelectableItem> items;
  final Function(SelectableItem, int)? callback;
 
  const ListSelection({super.key, required this.currentIndex, required this.items, this.callback});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {

        final first = index == 0;
        final last = index == items.length - 1;
        
        final radius = BorderRadius.vertical(
          top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
          bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
        );

        return Padding(
          padding: last ? const EdgeInsets.only(bottom: 0) : const EdgeInsets.only(bottom: defaultSpacing * 0.5),
          child: Material(
            color: currentIndex == index ? Get.theme.colorScheme.primary : Get.theme.colorScheme.background,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: () {
                if(callback != null) {
                  callback!(items[index], index);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(defaultSpacing),
                child: Row(
                  children: [
                    Icon(items[index].icon, color: items[index].iconColor ?? Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(defaultSpacing),
                    Text(items[index].label.tr, style: Get.theme.textTheme.bodyMedium!.copyWith(
                      color: Get.theme.colorScheme.onSurface
                    )),
                  ],
                ),
              ),
            ),
          )
        );
      },
    );
  }
}