import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarButton extends StatelessWidget {
  
  final Function() onTap;
  final String label;
  final bool selected;

  const SidebarButton({super.key, required this.onTap, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 1.5, vertical: defaultSpacing * 0.5),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.tertiaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}