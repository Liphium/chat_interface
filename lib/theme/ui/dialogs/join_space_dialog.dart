import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
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
    return DialogBase(
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
                  onTap: () {
                    SpaceController.join(widget.container);
                    Get.back();
                  },
                  smallCorners: true,
                  child: Center(
                    child: Text("yeah".tr, style: Get.theme.textTheme.labelMedium),
                  )),
              FJElevatedButton(
                  onTap: () => Get.back(),
                  smallCorners: true,
                  child: Center(
                    child: Text("no.got".tr, style: Get.theme.textTheme.labelMedium),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
