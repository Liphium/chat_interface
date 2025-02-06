import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_card.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ObjectContextMenu extends StatefulWidget {
  final TableObject object;
  final ContextMenuData data;

  const ObjectContextMenu({super.key, required this.data, required this.object});

  @override
  State<ObjectContextMenu> createState() => _ObjectContextMenuState();
}

class _ObjectContextMenuState extends State<ObjectContextMenu> {
  @override
  Widget build(BuildContext context) {
    final obj = widget.object;
    final inventory = obj is CardObject && obj.inventory;
    final additions = widget.object.getContextMenuAdditions();
    return SlidingWindowBase(
      title: const [], // Only for mobile (sort of)
      position: widget.data,
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: additions.length,
            itemBuilder: (context, index) {
              final addition = additions[index];
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : elementSpacing),
                child: ProfileButton(
                  icon: addition.icon,
                  iconColor: addition.iconColor,
                  color: addition.color,
                  label: addition.label,
                  loading: false.obs,
                  onTap: () {
                    addition.onTap.call(Get.find<TabletopController>());
                    if (addition.goBack) {
                      Get.back();
                    }
                  },
                ),
              );
            },
          ),
          if (!inventory) verticalSpacing(defaultSpacing),
          if (!inventory)
            ProfileButton(
              icon: Icons.crop_rotate,
              label: "tabletop.match_viewport".tr,
              loading: false.obs,
              onTap: () {
                widget.object.newRotation(-TabletopController.canvasRotation.value);
                Get.back();
              },
            ),
          if (!inventory) verticalSpacing(elementSpacing),
          if (!inventory)
            ProfileButton(
              icon: Icons.delete,
              label: "remove".tr,
              loading: false.obs,
              color: Get.theme.colorScheme.errorContainer,
              iconColor: Get.theme.colorScheme.error,
              onTap: () {
                widget.object.sendRemove();
                Get.back();
              },
            ),
        ],
      ),
    );
  }
}
