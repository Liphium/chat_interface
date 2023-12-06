import 'package:tabletop/layouts/canvas_manager.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/fj_textfield.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class CanvasAddDialog extends StatefulWidget {
  const CanvasAddDialog({super.key});

  @override
  State<CanvasAddDialog> createState() => _CanvasAddDialogState();
}

class _CanvasAddDialogState extends State<CanvasAddDialog> {

  final _controller = TextEditingController();
  final _error = Rx<String?>(null);

  @override
  void dispose() {
    _controller.dispose();
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
                  Text("Create a canvas", style: Get.theme.textTheme.titleMedium),
                  verticalSpacing(sectionSpacing),

                  Obx(() =>
                    FJTextField(
                      controller: _controller,
                      hintText: "Canvas name",
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

                      CanvasManager.saveCanvas(Canvas.create(_controller.text, ""));
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