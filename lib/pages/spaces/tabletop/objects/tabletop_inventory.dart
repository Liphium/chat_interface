import 'dart:convert';
import 'dart:isolate';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_card.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_painter.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_switch.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryObject extends TableObject {
  /// All cards currently in the inventory.
  final _cards = <CardObject>[];

  // Constants for the rendering
  static const double profilePicRadius = 100;
  static const double strokeWidth = 16;
  static const double spacing = 32;

  // The width and height of the inventory
  final width = AnimatedDouble(0);
  final height = AnimatedDouble(0);

  /// Get the entire rect that the inventory is inside of
  Rect getInventoryRect({DateTime? now, Offset? base, double? invisRangeX, double? invisRangeY}) {
    final fullWidth = now != null ? width.value(now) : width.realValue;
    final fullHeight = now != null ? height.value(now) : height.realValue;
    return Rect.fromLTWH(
      (base ?? location).dx - fullWidth / 2 + size.width / 2 - strokeWidth - (invisRangeX ?? 0),
      (base ?? location).dy - fullHeight - strokeWidth - (invisRangeY ?? 0),
      fullWidth + strokeWidth * 2 + (invisRangeX ?? 0) * 2,
      fullHeight + size.height / 2 + strokeWidth + (invisRangeY ?? 0) * 2,
    );
  }

  int inventoryHoverIndex = -1;

  InventoryObject(String id, int order, Offset location, Size size) : super(id, order, location, size, TableObjectType.inventory);

  @override
  void render(Canvas canvas, Offset location) {
    final now = DateTime.now();
    final ownInventory = TabletopController.inventory == this;
    final color = ownInventory ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.onSurface;

    // Draw a placeholder for the profile picture
    canvas.drawCircle(location + Offset(100, 100), 100, Paint()..color = color);

    // Prerender pass
    double totalWidth = 0;
    double biggestHeight = 0;
    int index = 0;
    for (var object in _cards) {
      totalWidth += object.size.width + (index == 0 ? 0 : spacing);
      if (object.size.height > biggestHeight) {
        biggestHeight = object.size.height;
      }
      index++;
    }

    // Add extra width if the inventory is hovered
    if (TabletopController.heldObject != null && ownInventory) {
      if (inventoryHoverIndex != -1) {
        totalWidth += TabletopController.heldObject!.size.width + spacing;
      }

      if (_cards.isEmpty) {
        biggestHeight = TabletopController.heldObject!.size.height;
      }
    }

    scale.setValue(1);
    width.setValue(totalWidth + spacing * 2);
    height.setValue(biggestHeight + spacing * 2);
    double counterWidth = totalWidth;

    // Draw the background
    final backRect = getInventoryRect(now: now, base: location);
    final backPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRRect(RRect.fromRectAndRadius(backRect, Radius.circular(32)), backPaint);

    // Check if the general inventory is hovered
    final bool inventoryHovered =
        backRect.contains(TabletopController.mousePos) && TabletopController.heldObject != null && TabletopController.heldObject != this;
    if (inventoryHovered) {
      inventoryHoverIndex = 0;
    } else {
      inventoryHoverIndex = -1;
    }

    // Render pass
    for (var object in _cards) {
      // Dragging behavior
      var calcX = location.dx + profilePicRadius + totalWidth / 2 - counterWidth;
      final calcY = location.dy - 32 - object.size.height;

      // If the inventory is hovered, check if hover index should be incremented
      if (calcX + object.size.width <= TabletopController.mousePos.dx && inventoryHovered) {
        inventoryHoverIndex++;
      } else if (inventoryHovered) {
        calcX += TabletopController.heldObject!.size.width + spacing;
      }

      // Draw the card and update positions
      object.positionOverwrite = true;
      if (TabletopController.hoveringObjects.contains(this) || location != this.location || object.positionX.lastValue == 0) {
        object.positionX.setRealValue(calcX);
        object.positionY.setRealValue(calcY);
      } else {
        object.positionX.setValue(calcX);
        object.positionY.setValue(calcY);
      }

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
        final hovered = rect.contains(TabletopController.mousePos) && TabletopController.heldObject == null;
        if (hovered && !TabletopController.hoveringObjects.contains(object)) {
          TabletopController.hoveringObjects.insert(0, object);
        } else if (!hovered && TabletopController.hoveringObjects.contains(object)) {
          TabletopController.hoveringObjects.remove(object);
        }
        object.inventory = true;
        if (!hovered) {
          object.scale.setValue(1);
        }
      }
      object.setFlipped(!ownInventory);

      final cardLocation = Offset(x, y);
      TabletopPainter.preDraw(canvas, cardLocation, object, now);
      object.renderCard(canvas, Offset(x, y), rect, false);
      TabletopPainter.postDraw(canvas);

      counterWidth -= rect.width + spacing;
    }
  }

  /// Add a card to the inventory
  void add(CardObject card, {int? index}) {
    // Insert the card into the inventory
    if (index == null) {
      _cards.add(card);
    } else {
      _cards.insert(index, card);
    }

    // Reset the card
    card.id = "";
    card.flipped = false;

    queue(() async {
      // Send the new data to the server
      await modifyData();
    });
  }

  /// Remove a card from the inventory
  void remove(CardObject card) {
    // Deletion has to be done here so the position of the card isn't reset
    _cards.remove(card);

    queue(() async {
      // Send the new data to the server
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
      obj.setFlipped(TabletopController.inventory != this, animation: false);

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
    return [
      if (TabletopController.inventory == this)
        ContextMenuAction(
          icon: Icons.logout,
          label: "Disown",
          onTap: (controller) {
            TabletopController.inventory = null;
          },
        ),
      if (TabletopController.inventory != this)
        ContextMenuAction(
          icon: Icons.login,
          label: "Make own",
          onTap: (controller) {
            TabletopController.inventory = this;
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
