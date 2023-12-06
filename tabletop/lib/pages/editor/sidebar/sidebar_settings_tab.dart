import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/pages/editor/sidebar/color_add_window.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_slider.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarSettingsTab extends StatefulWidget {
  const SidebarSettingsTab({super.key});

  @override
  State<SidebarSettingsTab> createState() => _SidebarSettingsTabState();
}

class _SidebarSettingsTabState extends State<SidebarSettingsTab> {

  final GlobalKey _addKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          //* Color manager
          Row(
            children: [
              Text("Colors", style: Get.theme.textTheme.labelLarge, textHeightBehavior: noTextHeight),
              const Expanded(child: SizedBox()),
              IconButton(
                key: _addKey,
                onPressed: () {
                  final RenderBox box = _addKey.currentContext?.findRenderObject() as RenderBox;
                  Get.dialog(ColorAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                }, 
                icon: Icon(Icons.add, color: Get.theme.colorScheme.onPrimary)
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          
          Obx(() =>
            ListView.builder(
              shrinkWrap: true,
              itemCount: controller.currentCanvas.value.colorManager.colors.length, 
              itemBuilder: (context, index) {
                final color = controller.currentCanvas.value.colorManager.colors.values.toList()[index];
                final expanded = false.obs;

                return Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing),
                  child: Material(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color: Get.theme.colorScheme.primaryContainer,
                    child: InkWell(
                      hoverColor: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      focusColor: Get.theme.colorScheme.primaryContainer,
                      onTap: () => expanded.value = !expanded.value,
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(color.name, style: Get.theme.textTheme.bodyMedium, textHeightBehavior: noTextHeight),
                                const Expanded(child: SizedBox()),
                                Obx(() =>
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: color.getColor(1.0, controller.currentCanvas.value.colorManager.saturation.value),
                                      borderRadius: BorderRadius.circular(elementSpacing),
                                    ),
                                  )
                                ),
                              ], 
                            ),

                            Obx(() {
                              final color = controller.currentCanvas.value.colorManager.colors.values.toList()[index];
                              final avoidSat = color.avoidSat.value;

                              return Visibility(
                                visible: expanded.value,
                                child: Column(
                                  children: [
                                    Visibility(
                                      visible: !avoidSat,
                                      child: FJSlider(
                                        min: 0.0,
                                        max: 360.0,
                                        value: color.hue.value,
                                        onChanged: (newVal) => color.hue.value = newVal,
                                        onChangeEnd: (finalVal) => controller.save(),
                                      ),
                                    ),
                                    FJSlider(
                                      min: 0.0,
                                      max: 1.0,
                                      value: color.luminosity.value,
                                      onChanged: (newVal) => color.luminosity.value = newVal,
                                      onChangeEnd: (finalVal) => controller.save(),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Switch(
                                          activeColor: Get.theme.colorScheme.secondary,
                                          trackColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Get.theme.colorScheme.primary : Get.theme.colorScheme.background),
                                          hoverColor: Get.theme.hoverColor,
                                          thumbColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.selected) ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.surface),
                                          value: avoidSat, 
                                          onChanged: (newVal) {
                                            color.avoidSat.value = newVal;
                                            controller.save();
                                          }
                                        ),
                                        FJElevatedButton(
                                          smallCorners: true,
                                          onTap: () => controller.currentCanvas.value.colorManager.removeColor(color.id), 
                                          child: Text("Delete", style: Get.theme.textTheme.labelMedium, textHeightBehavior: noTextHeight)
                                        ),
                                      ],
                                    )
                                  ]
                                )
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ),
          verticalSpacing(defaultSpacing),

          Visibility(
            visible: !controller.renderMode.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Saturation", style: Get.theme.textTheme.bodyMedium, textHeightBehavior: noTextHeight),
                Obx(() =>
                  FJSlider(
                    min: 0.0,
                    max: 1.0,
                    value: controller.currentCanvas.value.colorManager.saturation.value,
                    onChanged: (newVal) => controller.currentCanvas.value.colorManager.saturation.value = newVal,
                    onChangeEnd: (finalVal) => controller.save(),
                  )
                ),
                verticalSpacing(defaultSpacing),
              ],
            )
          )
        ],
      ),
    );
  }
}