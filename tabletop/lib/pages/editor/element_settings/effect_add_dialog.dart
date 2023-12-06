import 'package:tabletop/layouts/effects.dart';
import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/list_selection.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class EffectAddDialog extends StatefulWidget {
  const EffectAddDialog({super.key});

  @override
  State<EffectAddDialog> createState() => _CanvasAddDialogState();
}

class _CanvasAddDialogState extends State<EffectAddDialog> {

  final _controller = TextEditingController(), _width = TextEditingController(), _height = TextEditingController();

  final effects = [
    const SelectableItem("Padding", Icons.padding),
    const SelectableItem("Alignment", Icons.zoom_out_map),
    const SelectableItem("Inherit size", Icons.crop_square),
    const SelectableItem("Inherit position", Icons.radar),
    const SelectableItem("Element alignment", Icons.format_align_center),
  ];
  final current = 0.obs;

  @override
  void dispose() {
    _controller.dispose();
    _width.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 380,
        child: Animate(
          effects: [
            ScaleEffect(
              duration: 500.ms,
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: const ElasticOutCurve(0.9),
            )
          ],
          child: Material(
            elevation: 2.0,
            color: Get.theme.colorScheme.onBackground,
            borderRadius: BorderRadius.circular(dialogBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(dialogPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Add an effect", style: Get.theme.textTheme.titleMedium),
                  verticalSpacing(sectionSpacing),

                  Obx(() => 
                    ListSelection(
                      currentIndex: current.value, 
                      items: effects,
                      callback: (item, index) {
                        current.value = index;
                      },
                    )
                  ),

                  verticalSpacing(defaultSpacing),
                  FJElevatedButton(
                    onTap: () async {
                      final controller = Get.find<EditorController>();
                      switch(current.value) {
                        case 0:
                          controller.currentElement.value?.addEffect(PaddingEffect());
                          break;
                        case 1:
                          controller.currentElement.value?.addEffect(InheritSizeEffect());
                          break;
                        case 2:
                          controller.currentElement.value?.addEffect(InheritPositionEffect());
                          break;
                        case 3:
                          controller.currentElement.value?.addEffect(ElementAlignmentEffect());
                          break;
                      }

                      controller.save();
                      Get.back();
                    }, 
                    child: Center(child: Text("Add to element", style: Get.theme.textTheme.labelLarge)),
                  )
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}