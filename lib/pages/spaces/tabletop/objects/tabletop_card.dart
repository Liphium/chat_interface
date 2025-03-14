import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_inventory.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/pages/spaces/tabletop/objects/tabletop_deck.dart';
import 'package:chat_interface/services/spaces/tabletop/tabletop_object.dart';
import 'package:chat_interface/theme/ui/dialogs/image_preview_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardObject extends TableObject {
  AttachmentContainer? container;
  bool error = false;
  bool downloaded = false;
  bool inventory = false;
  ui.Image? image;
  Size? imageSize;
  Offset? lastPosition;
  bool flipped = false;
  bool inventoryFlip = false;
  final flipAnimation = AnimatedDouble(-1, duration: 750);

  CardObject(String id, int order, Offset location, Size size) : super(id, order, location, size, TableObjectType.card);

  static Future<CardObject?> downloadCard(AttachmentContainer container, Offset location, {String id = ""}) async {
    // Check if the container fits the new standard
    if (container.width == null || container.height == null) {
      return null;
    }

    // Make size fit with canvas standards (900x900 in this case)
    final size = Size(container.width!.toDouble(), container.height!.toDouble());
    final normalized = normalizeSize(size, cardNormalizer);
    final obj = CardObject(
      id,
      0,
      location,
      normalized,
    );
    obj.container = container;
    obj.imageSize = size;

    // Download the file
    unawaited(AttachmentController.downloadAttachment(container).then((success) async {
      if (success) {
        // Get the actual image and add it to the object
        final buffer = await ui.ImmutableBuffer.fromUint8List(await container.file!.readAsBytes());
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        final codec = await descriptor.instantiateCodec();
        obj.image = (await codec.getNextFrame()).image;
        obj.downloaded = true;
      } else {
        obj.error = true;
      }
    }));

    return obj;
  }

  static const double cardNormalizer = 900;

  /// Function to make sure images don't get too big
  static Size normalizeSize(Size size, double targetSize) {
    if (size.width > size.height) {
      final decreasingFactor = targetSize / size.width;
      size = Size((size.width * decreasingFactor).roundToDouble(), (size.height * decreasingFactor).roundToDouble());
    } else {
      final decreasingFactor = targetSize / size.height;
      size = Size((size.width * decreasingFactor).roundToDouble(), (size.height * decreasingFactor).roundToDouble());
    }

    return size;
  }

  /// Renders the decorations for flipped cards
  static void renderFlippedDecorations(Canvas canvas, Rect card) {
    final padding = sectionSpacing * 2;
    final spacing = sectionSpacing * 2;
    final size = 75.0;
    final cornerPaint = Paint()..color = Get.theme.colorScheme.onPrimary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(card.left + padding, card.top + padding, size, size), Radius.circular(spacing)),
      cornerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(card.left + padding, card.bottom - size - padding, size, size), Radius.circular(spacing)),
      cornerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(card.right - size - padding, card.top + padding, size, size), Radius.circular(spacing)),
      cornerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(card.right - size - padding, card.bottom - size - padding, size, size), Radius.circular(spacing)),
      cornerPaint,
    );
  }

  @override
  void render(Canvas canvas, Offset location) {
    final imageRect = Rect.fromLTWH(location.dx, location.dy, size.width, size.height);
    renderCard(canvas, location, imageRect);
  }

  void renderCard(Canvas canvas, Offset location, Rect imageRect) {
    if (error) {
      final paint = Paint()..color = Colors.red;
      canvas.drawRect(Rect.fromLTWH(location.dx, location.dy, size.width, size.height), paint);
      return;
    }

    // Draw the card
    if (downloaded) {
      final paint = Paint()..color = Colors.white;

      // Show that the card is about to be dropped
      if (TabletopController.heldObject == this && TabletopController.hoveringObjects.any((element) => element is DeckObject)) {
        paint.color = Colors.white.withAlpha(120);
      }

      // Check if the thing should be flipped in case moved and next to an inventory
      if ((lastPosition != location || lastPosition == null) && !inventory) {
        final center = location + Offset(size.width / 2, size.height / 2);
        bool found = false;
        for (var object in TabletopController.objects.values) {
          if (object is InventoryObject && TabletopController.inventory != object) {
            if (object.getInventoryRect(invisRangeX: size.width / 2, invisRangeY: size.height / 2).contains(center)) {
              found = true;
            }
          }
        }
        inventoryFlip = found;
      }
      lastPosition = location;

      // Set the new value of the flipped animation
      if (flipAnimation.realValue == -1) {
        // Initialize with actual flip state and don't animate it
        flipAnimation.setRealValue(flipped || inventoryFlip ? 1 : 0);
      } else {
        flipAnimation.setValue(flipped || inventoryFlip ? 1 : 0);
      }

      if (image == null) {
        canvas.clipRRect(RRect.fromRectAndRadius(imageRect, Radius.circular(sectionSpacing * 2)));
        canvas.drawRect(
          imageRect,
          Paint()..color = Colors.red,
        );
      } else {
        // Rotation for the flip animation
        canvas.save();
        final focalX = location.dx + imageRect.width / 2;
        final focalY = location.dy + imageRect.height / 2;
        canvas.translate(focalX, focalY);
        final currentFlip = flipAnimation.value(DateTime.now());

        final Matrix4 matrix = Matrix4.identity()
          ..setEntry(3, 2, 0) // perspective
          ..rotateY(math.pi * currentFlip);

        canvas.transform(matrix.storage);
        canvas.translate(-focalX, -focalY);

        canvas.clipRRect(RRect.fromRectAndRadius(imageRect, Radius.circular(sectionSpacing * 2)));

        // Check if the animation says it's flipped or not
        if (currentFlip > 0.5) {
          canvas.drawRect(
            imageRect,
            Paint()..color = Get.theme.colorScheme.primaryContainer,
          );
          renderFlippedDecorations(canvas, imageRect);
        } else {
          canvas.drawImageRect(
            image!,
            Rect.fromLTWH(0, 0, size.width * (imageSize!.width / size.width), size.height * (imageSize!.height / size.height)),
            imageRect,
            paint,
          );
        }

        canvas.restore();
      }
      return;
    }

    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(location.dx, location.dy, size.width, size.height), paint);
  }

  @override
  Future<void> handleData(String data) async {
    // Download attached container
    final json = jsonDecode(data);
    flipped = json["flip"] ?? false;

    // Check if it's the same object and ignore to prevent flickering
    if (container?.id != json["id"]) {
      return;
    }

    // Download the new image
    final type = await AttachmentController.checkLocations(json["i"], StorageType.cache);
    container = AttachmentController.fromJson(type, jsonDecode(data));
    final download = await AttachmentController.downloadAttachment(container!);
    if (!download) {
      error = true;
      sendLog("failed to download card");
      return;
    }

    // Get image from file
    final buffer = await ui.ImmutableBuffer.fromUint8List(await container!.file!.readAsBytes());
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final codec = await descriptor.instantiateCodec();
    image = (await codec.getNextFrame()).image;
    imageSize = Size(descriptor.width.toDouble(), descriptor.height.toDouble());
    downloaded = true;
  }

  @override
  String getData() {
    final json = container!.toJson();
    json["flip"] = flipped;
    return jsonEncode(json);
  }

  @override
  void runAction() {
    if (inventory) {
      setFlipped(!flipped);
    } else {
      queue(() async {
        flipped = !flipped;
        final result = await modifyData();
        if (!result) {
          sendLog("something went wrong");
        }
      });
    }
  }

  void setFlipped(bool newFlipped, {bool animation = true}) {
    flipped = newFlipped;
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      if (!inventory)
        ContextMenuAction(
          icon: Icons.login,
          label: 'Put into inventory',
          onTap: () {
            intoInventory();
          },
        ),
      ContextMenuAction(
        icon: Icons.fullscreen,
        goBack: false,
        label: 'View in image viewer',
        onTap: () {
          sendLog("viewing..");
          Get.back();
          Get.dialog(ImagePreviewWindow(image: image));
        },
      ),
    ];
  }

  List<ContextMenuAction> getInventoryContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.fullscreen,
        label: 'View in image viewer',
        onTap: () {
          Get.dialog(ImagePreviewWindow(image: image));
        },
      ),
    ];
  }

  Future<void> intoInventory({int? index}) async {
    positionX.setRealValue(location.dx);
    positionY.setRealValue(location.dy);
    sendRemove();
    if (index != null) {
      TabletopController.inventory!.add(this, index: index);
    } else {
      (await TabletopController.getOrCreateInventory())?.add(this);
    }
  }
}
