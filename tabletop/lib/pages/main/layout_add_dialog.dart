import 'package:tabletop/layouts/layout_manager.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_textfield.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class LayoutAddDialog extends StatefulWidget {
  const LayoutAddDialog({super.key});

  @override
  State<LayoutAddDialog> createState() => _LayoutAddDialogState();
}

class _LayoutAddDialogState extends State<LayoutAddDialog> {

  final _controller = TextEditingController(), _width = TextEditingController(), _height = TextEditingController();
  final _error = Rx<String?>(null);

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
                  Text("Create a layout", style: Get.theme.textTheme.titleMedium),
                  verticalSpacing(sectionSpacing),
          
                  Text("Size of the layout", style: Get.theme.textTheme.bodyMedium),
                  verticalSpacing(defaultSpacing),

                  Row(
                    children: [
                      Expanded(
                        child: FJTextField(
                          controller: _width,
                          hintText: "Width",
                          errorText: _error.value,
                        ),
                      ),
                      horizontalSpacing(defaultSpacing),
                      Text("X", style: Get.theme.textTheme.labelLarge),
                      horizontalSpacing(defaultSpacing),
                      Expanded(
                        child: FJTextField(
                          controller: _height,
                          hintText: "Height",
                          errorText: _error.value,
                        ),
                      )
                    ],
                  ),
                  verticalSpacing(defaultSpacing),

                  verticalSpacing(defaultSpacing),
                  Text("Name of the layout", style: Get.theme.textTheme.bodyMedium),
                  verticalSpacing(defaultSpacing),

                  Obx(() =>
                    FJTextField(
                      controller: _controller,
                      hintText: "Layout name",
                      errorText: _error.value,
                    )
                  ),
                  verticalSpacing(defaultSpacing),
                  FJElevatedButton(
                    onTap: () {
                      if(_controller.text.length < 3) {
                        _error.value = "Must be at least 3 characters long.";
                        return;
                      }

                      final width = int.tryParse(_width.text);
                      final height = int.tryParse(_height.text);
                      if(width == null || height == null) {
                        _error.value = "Width and height must be numbers.";
                        return;
                      }

                      LayoutManager.saveLayout(Layout.create(_controller.text, ""));
                      Get.back();
                    }, 
                    child: Center(child: Text("Create", style: Get.theme.textTheme.labelLarge)),
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