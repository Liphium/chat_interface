import 'dart:convert';
import 'dart:isolate';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/objects/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryObject extends TableObject {
  /// All cards currently in the inventory.
  final _cards = <CardObject>[];

  // The radius of the profile picture
  final profilePicRadius = 100;

  // The width and height of the biggest card
  final width = AnimatedDouble(500);
  final height = AnimatedDouble(500);

  int inventoryHoverIndex = -1;

  InventoryObject(String id, int order, Offset location, Size size) : super(id, order, location, size, TableObjectType.inventory);

  @override
  void render(Canvas canvas, Offset location, TabletopController controller) {
    final now = DateTime.now();
    final ownInventory = controller.inventory == this;

    // Draw a placeholder for the profile picture
    canvas.drawCircle(location + Offset(100, 100), 100, Paint()..color = Colors.white);

    // Prerender pass
    double totalWidth = 0;
    int index = 0;
    for (var object in _cards) {
      totalWidth += object.size.width + (index == 0 ? 0 : 32);
      index++;
    }
    scale.setValue(1);
    double counterWidth = totalWidth;

    // Render pass
    for (var object in _cards) {
      if (object.downloaded) {
        final x = object.positionX.value(now);
        final y = object.positionY.value(now);
        final rect = Rect.fromLTWH(
          x,
          y,
          object.size.width,
          object.size.height,
        );

        // Tell the controller about the hover state
        if (ownInventory) {
          final hovered = rect.contains(controller.mousePos) && controller.heldObject == null;
          if (hovered && !controller.hoveringObjects.contains(object)) {
            controller.hoveringObjects.insert(0, object);
          } else if (!hovered && controller.hoveringObjects.contains(object)) {
            controller.hoveringObjects.remove(object);
          }
          object.inventory = true;
          if (!hovered) {
            object.scale.setValue(1);
          }
        }
        object.setFlipped(!ownInventory);

        // Dragging behavior
        var calcX = location.dx + profilePicRadius + totalWidth / 2 - counterWidth;
        final calcY = location.dy - 32 - rect.height;

        // Draw the card and update positions
        object.positionOverwrite = true;
        if (controller.hoveringObjects.contains(this) || object.positionX.lastValue == 0) {
          object.positionX.setRealValue(calcX);
          object.positionY.setRealValue(calcY);
        } else {
          object.positionX.setValue(calcX);
          object.positionY.setValue(calcY);
        }

        final cardLocation = Offset(x, y);
        TabletopPainter.preDraw(canvas, cardLocation, object, now);
        object.renderCard(canvas, Offset(x, y), controller, rect, false);
        TabletopPainter.postDraw(canvas);

        counterWidth -= rect.width + 32;
      }
    }
  }

  /// Add a card to the inventory
  void add(CardObject card, {int? index}) {
    queue(() async {
      // Insert the card into the inventory
      if (index == null) {
        _cards.add(card);
      } else {
        _cards.insert(index, card);
      }

      // Send the new data to the server
      // TODO: We should properly put out some kind of error message here
      await modifyData();
    });
  }

  /// Remove a card from the inventory
  void remove(CardObject card) {
    queue(() async {
      _cards.remove(card);

      // Send the new data to the server
      // TODO: We should properly put out some kind of error message here
      await modifyData();
    });
  }

  @override
  Future<void> handleData(String data) async {
    // Unpack the card list (json) in an isolate
    final cardList = await Isolate.run(() async {
      return jsonDecode(data);
    });

    // Remove all cards that are not in the new data
    _cards.removeWhere((c) => !cardList.any((o) => o["i"] == c.container?.id && o["u"] == c.container?.url));

    // Go through all cards and unpack them (only works in main thread cause sodium)
    final controller = Get.find<AttachmentController>();
    int index = -1;
    for (var card in cardList) {
      index++;

      // Check if the card is already in the inventory
      if (_cards.any((c) => c.container?.id == card["i"] && c.container?.url == card["u"])) {
        continue;
      }

      final type = await AttachmentController.checkLocations(card["i"], StorageType.cache);
      final container = controller.fromJson(type, card);

      // Create a card object from it
      final obj = await CardObject.downloadCard(container, location);
      if (obj == null) {
        continue;
      }
      obj.setFlipped(Get.find<TabletopController>().inventory != this, animation: false);

      // Insert the card at the index where it was not found
      _cards.insert(index, obj);
    }
  }

  @override
  String getData() {
    final list = <Map<String, dynamic>>[];
    for (var card in _cards) {
      list.add(card.container!.toJson());
    }

    return jsonEncode(list);
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    final controller = Get.find<TabletopController>();
    return [
      if (controller.inventory == this)
        ContextMenuAction(
          icon: Icons.logout,
          label: "Disown",
          onTap: (controller) {
            controller.inventory = null;
          },
        ),
      if (controller.inventory != this)
        ContextMenuAction(
          icon: Icons.login,
          label: "Make own",
          onTap: (controller) {
            controller.inventory = this;
          },
        )
    ];
  }
}

class InventoryObjectWindow extends StatefulWidget {
  final Offset location;
  final InventoryObject? object;

  const InventoryObjectWindow({
    super.key,
    required this.location,
    this.object,
  });

  @override
  State<InventoryObjectWindow> createState() => _InventoryObjectWindowState();
}

class _InventoryObjectWindowState extends State<InventoryObjectWindow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DialogBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Inventory settings".tr, style: Get.theme.textTheme.titleMedium),
          verticalSpacing(sectionSpacing),
          Row(
            children: [
              Text("Show cards to other players", style: theme.textTheme.bodyMedium),
              const Spacer(),
              FJSwitch(
                value: false,
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          FJElevatedButton(
            onTap: () {
              Get.back();
              if (widget.object != null) {
                return;
              }
              final object = InventoryObject("", 0, widget.location, Size(200, 200));
              object.sendAdd();
            },
            child: Center(
              child: Text((widget.object != null ? "edit" : "create").tr, style: Get.theme.textTheme.labelLarge),
            ),
          )
        ],
      ),
    );
  }
}
