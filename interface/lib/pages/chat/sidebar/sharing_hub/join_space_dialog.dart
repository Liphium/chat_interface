import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class JoinSpaceDialog extends StatefulWidget {

  final SpaceConnectionContainer container;

  const JoinSpaceDialog({super.key, required this.container});

  @override
  State<JoinSpaceDialog> createState() => _JoinSpaceDialogState();
}

class _JoinSpaceDialogState extends State<JoinSpaceDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
                  Text("join.space".tr, style: Get.theme.textTheme.titleMedium),
                  verticalSpacing(defaultSpacing),
                  Text("join.space.popup".tr, style: Get.theme.textTheme.bodyMedium),
                  verticalSpacing(sectionSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FJElevatedButton(
                        onTap: () => Get.back(), // TODO: Join
                        smallCorners: true,
                        child: Center(child: Text("yeah".tr, style: Get.theme.textTheme.labelMedium),)
                      ),
                      FJElevatedButton(
                        onTap: () => Get.back(), 
                        smallCorners: true,
                        child: Center(child: Text("no.got".tr, style: Get.theme.textTheme.labelMedium),)
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}