import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_deck.dart';
import 'package:chat_interface/pages/spaces/tabletop/tabletop_page.dart';
import 'package:chat_interface/theme/ui/dialogs/attachment_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardObject extends TableObject {
  late AttachmentContainer container;
  bool error = false;
  bool downloaded = false;
  bool inventory = false;
  ui.Image? image;
  Size? imageSize;
  bool flipped = false;
  final flipAnimation = AnimatedDouble(0, duration: 750);

  CardObject(String id, Offset location, Size size) : super(id, location, size, TableObjectType.card);

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
      location,
      normalized,
    );
    obj.container = container;
    obj.imageSize = size;

    // Download the file
    Get.find<AttachmentController>().downloadAttachment(container).then((success) async {
      if (success) {
        // Get the actual image and add it to the object
        final buffer = await ui.ImmutableBuffer.fromUint8List(await File(container.filePath).readAsBytes());
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        final codec = await descriptor.instantiateCodec();
        obj.image = (await codec.getNextFrame()).image;
        obj.downloaded = true;
      } else {
        obj.error = true;
      }
    });

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
  static void renderFlippedDecorations(Canvas canvas, Rect card, {bool ui = false}) {
    final padding = ui ? sectionSpacing : sectionSpacing * 2;
    final spacing = ui ? defaultSpacing + defaultSpacing / 2 : sectionSpacing * 2;
    final size = ui ? 30.0 : 75.0;
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
  void render(Canvas canvas, Offset location, TabletopController controller) {
    final imageRect = Rect.fromLTWH(location.dx, location.dy, size.width, size.height);
    renderCard(canvas, location, controller, imageRect, false);
  }

  void renderCard(Canvas canvas, Offset location, TabletopController controller, Rect imageRect, bool ui) {
    if (error) {
      final paint = Paint()..color = Colors.red;
      canvas.drawRect(Rect.fromLTWH(location.dx, location.dy, size.width, size.height), paint);
      return;
    }

    // Draw the card
    if (downloaded) {
      final paint = Paint()..color = Colors.white;

      // Show that the card is about to be dropped
      if (controller.heldObject == this && controller.hoveringObjects.any((element) => element is DeckObject)) {
        paint.color = Colors.white.withOpacity(0.5);
      }

      if (image == null) {
        canvas.clipRRect(RRect.fromRectAndRadius(imageRect, Radius.circular(ui ? sectionSpacing : sectionSpacing * 2)));
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
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(math.pi * currentFlip);
        canvas.transform(matrix.storage);
        canvas.translate(-focalX, -focalY);

        canvas.clipRRect(RRect.fromRectAndRadius(imageRect, Radius.circular(ui ? sectionSpacing : sectionSpacing * 2)));

        // Check if the animation says it's flipped or not
        if (currentFlip > 0.5) {
          canvas.drawRect(
            imageRect,
            Paint()..color = Get.theme.colorScheme.primaryContainer,
          );
          renderFlippedDecorations(canvas, imageRect, ui: ui);
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
  void handleData(String data) async {
    sendLog("handling data");
    // Download attached container
    final json = jsonDecode(data);
    flipped = json["flip"] ?? false;
    flipAnimation.setValue(flipped ? 1 : 0);
    final type = await AttachmentController.checkLocations(json["id"], StorageType.cache);
    container = AttachmentContainer.fromJson(type, jsonDecode(data));
    final download = await Get.find<AttachmentController>().downloadAttachment(container);
    if (!download) {
      error = true;
      sendLog("failed to download card");
      return;
    }

    // Get image from file
    final buffer = await ui.ImmutableBuffer.fromUint8List(await File(container.filePath).readAsBytes());
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final codec = await descriptor.instantiateCodec();
    image = (await codec.getNextFrame()).image;
    imageSize = Size(descriptor.width.toDouble(), descriptor.height.toDouble());
    downloaded = true;
  }

  @override
  String getData() {
    final json = container.toJson();
    json["flip"] = flipped;
    return jsonEncode(json);
  }

  @override
  void runAction(TabletopController controller) {
    if (inventory) {
      flipped = !flipped;
      flipAnimation.setValue(flipped ? 0 : 1);
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

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      if (!inventory)
        ContextMenuAction(
          icon: Icons.login,
          label: 'Put into inventory',
          onTap: (controller) {
            intoInventory(controller);
          },
        ),
      ContextMenuAction(
        icon: Icons.fullscreen,
        goBack: false,
        label: 'View in image viewer',
        onTap: (controller) {
          sendLog("viewing..");
          Get.back();
          Get.dialog(ImagePreviewWindow(file: File(container.filePath)));
        },
      ),
    ];
  }

  List<ContextMenuAction> getInventoryContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.fullscreen,
        label: 'View in image viewer',
        onTap: (controller) {
          Get.dialog(ImagePreviewWindow(file: File(container.filePath)));
        },
      ),
    ];
  }

  void intoInventory(TabletopController controller, {int? index}) {
    final localPos = TabletopView.worldToLocalPos(location, controller.canvasZoom, controller.canvasOffset, controller);
    positionX.setRealValue(localPos.dx);
    positionY.setRealValue(localPos.dy);
    sendRemove();
    if (index != null) {
      controller.inventory.insert(index, this);
    } else {
      controller.inventory.add(this);
    }
  }
}
