import 'package:tabletop/pages/editor/editor_controller.dart';
import 'package:tabletop/theme/fj_button.dart';
import 'package:tabletop/theme/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ErrorDialog extends StatefulWidget {
  const ErrorDialog({super.key});

  @override
  State<ErrorDialog> createState() => _CanvasAddDialogState();
}

class _CanvasAddDialogState extends State<ErrorDialog> {

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditorController>();

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

                  Text("Error", style: Get.theme.textTheme.titleMedium),
                  verticalSpacing(sectionSpacing),

                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.errorMessages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing),
                        child: Text(controller.errorMessages[index], style: Get.theme.textTheme.labelMedium)
                      );
                    },
                  ),

                  FJElevatedButton(
                    onTap: () async {
                      Get.back();
                    }, 
                    child: Center(child: Text("Alright", style: Get.theme.textTheme.labelLarge)),
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