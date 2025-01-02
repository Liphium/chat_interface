import 'package:chat_interface/controller/spaces/tabletop/objects/tabletop_inventory.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/objects/tabletop_deck.dart';
import 'package:chat_interface/controller/spaces/tabletop/objects/tabletop_text.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ObjectCreateMenu extends StatefulWidget {
  final Offset location;

  const ObjectCreateMenu({super.key, required this.location});

  @override
  State<ObjectCreateMenu> createState() => _ObjectCreateMenuState();
}

class _ObjectCreateMenuState extends State<ObjectCreateMenu> {
  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("tabletop.object.create".tr, style: Get.textTheme.titleMedium),
          verticalSpacing(sectionSpacing),
          ListView.builder(
            shrinkWrap: true,
            itemCount: TableObjectType.values.length,
            itemBuilder: (context, index) {
              final type = TableObjectType.values[index];
              if (!type.creatable) {
                return const SizedBox();
              }
              return Padding(
                padding: index == 0 ? const EdgeInsets.all(0) : const EdgeInsets.only(top: defaultSpacing),
                child: Material(
                  color: Get.theme.colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    onTap: () async {
                      TableObject? object;
                      switch (type) {
                        case TableObjectType.text:
                          Get.back();
                          object = await Get.dialog(TextObjectCreationWindow(location: widget.location));
                        case TableObjectType.deck:
                          Get.back();
                          object = await Get.dialog(DeckObjectCreationWindow(location: widget.location));
                        case TableObjectType.inventory:
                          Get.back();
                          object = InventoryObject("", 0, widget.location, Size(200, 200));
                        default:
                          break;
                      }
                      await object?.sendAdd();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(defaultSpacing),
                      child: Row(
                        children: [
                          Icon(type.icon, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(defaultSpacing),
                          Text("tabletop.object.${type.name}".tr, style: Get.textTheme.labelMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
