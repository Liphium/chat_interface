import 'dart:convert';
import 'dart:isolate';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_decks.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeckObject extends TableObject {
  /// Card ID -> Card data
  var cards = <String, AttachmentContainer>{};

  /// All card ids in the order they are in the deck (we separate this from the cards map so we don't have
  /// to send all the card data to the server twice if a card is in there twice)
  var cardOrder = <String>[];

  // The width and height of the current top card
  final width = AnimatedDouble(500);
  final height = AnimatedDouble(500);

  DeckObject(String id, int order, Offset location, Size size) : super(id, order, location, size, TableObjectType.deck);

  factory DeckObject.createFromDeck(Offset location, TabletopDeck deck) {
    final obj = DeckObject("", 0, location, const Size(500, 500));
    for (var card in deck.cards) {
      obj.cards[card.id] = card;
      for (int i = 0; i < (deck.amounts[card.id] ?? 1); i++) {
        obj.cardOrder.add(card.id);
      }
    }
    obj.setWidthAndHeight(replace: true);
    obj.size = Size(obj.width.realValue, obj.height.realValue);

    return obj;
  }

  @override
  void render(Canvas canvas, Offset location, TabletopController controller) {
    // Draw a stack
    final now = DateTime.now();
    final currentWidth = width.value(now);
    final currentHeight = height.value(now);
    final cardRect = RRect.fromLTRBR(
      location.dx,
      location.dy,
      location.dx + currentWidth,
      location.dy + currentHeight,
      const Radius.circular(sectionSpacing * 2),
    );
    canvas.drawRRect(
      cardRect,
      Paint()..color = Get.theme.colorScheme.primaryContainer,
    );

    // Draw the flipped icon on the card
    CardObject.renderFlippedDecorations(canvas, cardRect.outerRect);

    // Draw the counter
    const counterSize = 200;
    final rect = RRect.fromLTRBR(
      location.dx + currentWidth / 2 - counterSize / 2,
      location.dy + currentHeight / 2 - counterSize / 2,
      location.dx + currentWidth / 2 + counterSize / 2,
      location.dy + currentHeight / 2 + counterSize / 2,
      const Radius.circular(sectionSpacing * 2),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Get.theme.colorScheme.inverseSurface,
    );
    var textSpan = TextSpan(
      text: cardOrder.length.toString(),
      style: TextStyle(
        color: Get.theme.colorScheme.onPrimary,
        fontSize: 100,
        fontFamily: "Roboto Mono",
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(rect.left + rect.width / 2 - textPainter.size.width / 2, rect.top + rect.height / 2 - textPainter.size.height / 2));
  }

  @override
  Future<void> handleData(String data) async {
    cardOrder.clear();
    cards.clear();

    // Unpack all the json in an isolate
    final json = await Isolate.run(() async {
      return jsonDecode(data);
    });

    cardOrder = (json["order"] as List<dynamic>).cast<String>();

    // Go through all cards and unpack them (only works in main thread cause sodium)
    final cardMap = json["cards"] as Map<String, dynamic>;
    final controller = Get.find<AttachmentController>();
    for (var card in cardMap.values) {
      final type = await AttachmentController.checkLocations(card["i"], StorageType.cache);
      cards[card["i"]] = controller.fromJson(type, card);
    }

    // Set the width and height from the order
    setWidthAndHeight(replace: false);
  }

  /// Refresh the current top card and set width and height of it
  void setWidthAndHeight({bool replace = false}) {
    final top = cardOrder.firstOrNull;
    if (top != null) {
      final card = cards[top]!;
      final newSize = CardObject.normalizeSize(Size(card.width!.toDouble(), card.height!.toDouble()), CardObject.cardNormalizer);
      if (replace) {
        width.setRealValue(newSize.width);
        height.setRealValue(newSize.height);
      } else {
        width.setValue(newSize.width);
        height.setValue(newSize.height);
      }
      size = newSize;
    }
  }

  @override
  String getData() {
    final map = <String, dynamic>{};
    for (var card in cards.values) {
      map[card.id] = card.toJson();
    }

    return jsonEncode({
      "cards": map,
      "order": cardOrder.toList(),
    });
  }

  @override
  void runAction(TabletopController controller) {
    drawCardIntoInventory(controller);
  }

  /// Draw a card from the deck into the inventory
  Future<void> drawCardIntoInventory(TabletopController controller) async {
    if (cardOrder.isEmpty) {
      return;
    }
    queue(() async {
      // Get the card and its container
      final cardId = cardOrder.removeAt(0);
      final container = cards[cardId]!;

      // Remove the container of the card from the cards map in case it is no longer needed
      if (!cardOrder.contains(cardId)) {
        cards.remove(cardId);
      }

      // Download the card and do all the other magic required for this
      final obj = await CardObject.downloadCard(container, controller.mousePos);
      setWidthAndHeight();
      final result = await modifyData();
      if (!result) return;
      if (obj == null) return;
      obj.positionX.setRealValue(controller.mousePosUnmodified.dx - (obj.size.width / 2) * controller.canvasZoom);
      obj.positionY.setRealValue(controller.mousePosUnmodified.dy - (obj.size.height / 2) * controller.canvasZoom);
      controller.inventory.add(obj);
    });
  }

  /// Shuffle the deck
  void shuffle() {
    queue(() async {
      cardOrder.shuffle();
      await modifyData();
    });
  }

  void addCard(CardObject obj) {
    queue(() async {
      // Add teh card to the local deck
      cards[obj.container!.id] = obj.container!;
      cardOrder.add(obj.container!.id);

      // Update the deck on the server
      final valid = await modifyData();
      if (!valid) {
        return;
      }

      // Remove the card from the table
      obj.sendRemove();
    });
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.shuffle,
        label: 'Shuffle',
        onTap: (controller) {
          shuffle();
          Get.back();
        },
      ),
    ];
  }
}

class DeckObjectCreationWindow extends StatefulWidget {
  final Offset location;

  const DeckObjectCreationWindow({super.key, required this.location});

  @override
  State<DeckObjectCreationWindow> createState() => _DeckSelectionWindowState();
}

class _DeckSelectionWindowState extends State<DeckObjectCreationWindow> {
  // Deck list
  final _decks = <TabletopDeck>[].obs;
  final _loading = true.obs;
  final _error = false.obs;

  @override
  void initState() {
    getDecksFromServer();
    super.initState();
  }

  Future<void> getDecksFromServer() async {
    final decks = await TabletopDecks.listDecks();
    if (decks == null) {
      _error.value = true;
      _loading.value = false;
      return;
    }
    _decks.addAll(decks);
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Obx(() {
        if (_loading.value) {
          return CircularProgressIndicator(
            color: Get.theme.colorScheme.onPrimary,
          );
        }

        if (_error.value) {
          return ErrorContainer(
            message: "settings.tabletop.decks.error".tr,
            expand: true,
          );
        }

        if (_decks.isEmpty) {
          return ErrorContainer(
            message: "tabletop.object.deck.choose_empty".tr,
            expand: true,
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("tabletop.object.deck.choose".tr, style: Get.theme.textTheme.titleMedium),
            verticalSpacing(sectionSpacing),
            ListView.builder(
              itemCount: _decks.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final deck = _decks[index];
                return Padding(
                  padding: index == 0 ? const EdgeInsets.all(0) : const EdgeInsets.only(top: defaultSpacing),
                  child: Material(
                    color: Get.theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: InkWell(
                      onTap: () {
                        if (deck.cards.any((card) => card.width == null || card.height == null)) {
                          showErrorPopup("error", "tabletop.object.deck.incompatible".tr);
                          return;
                        }
                        final object = DeckObject.createFromDeck(widget.location, deck);
                        Get.back(result: object);
                      },
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(deck.name, style: Get.theme.textTheme.labelLarge),
                                verticalSpacing(elementSpacing),
                                Obx(
                                  () => Text(
                                    "decks.cards".trParams({"count": deck.cards.length.toString()}),
                                    style: Get.theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        );
      }),
    );
  }
}
