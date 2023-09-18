import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class ConfirmWindow extends StatelessWidget {

  final String title;
  final String text;
  final Function() onConfirm;
  final Function() onDecline;

  const ConfirmWindow({super.key, required this.title, required this.text, required this.onConfirm, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Animate(
            effects: [
              ScaleEffect(
                duration: 500.ms,
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: const ElasticOutCurve(0.9),
              )
            ],
            child: SizedBox(
              width: 300,
              child: Material(
                elevation: 2.0,
                color: Get.theme.colorScheme.onBackground,
                borderRadius: BorderRadius.circular(modelBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.all(modelPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: Get.theme.textTheme.titleMedium),
                      verticalSpacing(defaultSpacing),
                      Text(text, style: Get.theme.textTheme.bodyMedium),
                      verticalSpacing(sectionSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: FJElevatedButton(
                              onTap: () {
                                Get.back();
                                onConfirm();
                              }, 
                              child: Center(child: Text("yes".tr, style: Get.theme.textTheme.titleMedium),)
                            ),
                          ),
                          horizontalSpacing(defaultSpacing),
                          Expanded(
                            child: FJElevatedButton(
                              onTap: () {
                                Get.back();
                                onDecline();
                              }, 
                              child: Center(child: Text("no".tr, style: Get.theme.textTheme.titleMedium),)
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}