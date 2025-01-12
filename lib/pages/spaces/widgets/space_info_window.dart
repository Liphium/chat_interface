import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceInfoWindow extends StatelessWidget {
  const SpaceInfoWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SpacesController>();
    final memberController = Get.find<SpaceMemberController>();

    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Space #${controller.id.value}", style: Get.theme.textTheme.titleMedium),
          ),
          verticalSpacing(defaultSpacing),
          Row(
            children: [
              Text("Disable Tabletop cursors"),
              const Spacer(),
              Obx(
                () => FJSwitch(
                  value: Get.find<TabletopController>().disableCursorSending.value,
                  onChanged: (b) => Get.find<TabletopController>().disableCursorSending.value = b,
                ),
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          Text("Members", style: Get.theme.textTheme.labelMedium),
          verticalSpacing(elementSpacing),
          Obx(
            () {
              return Column(
                children: memberController.members.values.map((member) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: elementSpacing),
                    child: Row(
                      children: [
                        Text(member.friend.displayName.value, style: Get.theme.textTheme.bodyMedium),
                        horizontalSpacing(defaultSpacing),
                        Text("#${member.id}", style: Get.theme.textTheme.bodyMedium),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
