import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ColorPreview extends StatefulWidget {
  final Signal<ColorFactory?> factory;
  final bool mobile;

  const ColorPreview({super.key, required this.factory, this.mobile = false});

  @override
  State<ColorPreview> createState() => _ColorPreviewState();
}

class _ColorPreviewState extends State<ColorPreview> {
  @override
  Widget build(BuildContext context) {
    return Watch((ctx) {
      final colors = widget.factory.value!;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
        child: Container(
          decoration: BoxDecoration(
            color: colors.getBackground2(),
            borderRadius: BorderRadius.circular(defaultSpacing),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: sectionSpacing,
                  right: sectionSpacing,
                  left: sectionSpacing,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color: colors.getPrimaryContainer(),
                  ),
                  padding: const EdgeInsets.all(defaultSpacing),
                  height: 60,
                  child: Row(
                    children: [
                      Icon(Icons.color_lens, color: colors.getPrimary(), size: 40),
                      horizontalSpacing(defaultSpacing),
                      Expanded(
                        child: Text("theme.primary".tr, style: Get.theme.textTheme.labelLarge),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(sectionSpacing),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color: colors.getSecondaryContainer(),
                  ),
                  padding: const EdgeInsets.all(defaultSpacing),
                  height: 60,
                  child: Row(
                    children: [
                      Icon(Icons.color_lens, color: colors.getSecondary(), size: 40),
                      horizontalSpacing(defaultSpacing),
                      Expanded(
                        child: Text("theme.secondary".tr, style: Get.theme.textTheme.labelLarge),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpacing(widget.mobile ? 30 : 100),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  color: colors.getBackground3(),
                ),
                padding: const EdgeInsets.all(defaultSpacing),
                height: 60,
                child: Row(
                  children: [
                    Icon(Icons.person, color: colors.getPrimary(), size: 40),
                    horizontalSpacing(defaultSpacing),
                    Expanded(
                      child: Text(
                        StatusController.name.value,
                        style: Get.theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
