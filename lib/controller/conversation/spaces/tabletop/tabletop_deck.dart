import 'dart:convert';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_card.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_decks.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeckObject extends TableObject {
  /// Card ID -> Card data
  final cards = <String, AttachmentContainer>{};

  /// All card ids in the order they are in the deck (we separate this from the cards map so we don't have
  /// to send all the card data to the server twice if a card is in there twice)
  final order = <String>[];

  DeckObject(String id, Offset location, Size size) : super(id, location, size, TableObjectType.deck);

  factory DeckObject.createFromDeck(Offset location, TabletopDeck deck) {
    final obj = DeckObject("", location, const Size(500, 500));
    for (var card in deck.cards) {
      obj.cards[card.id] = card;
      for (int i = 0; i < (deck.amounts[card.id] ?? 1); i++) {
        obj.order.add(card.id);
      }
    }
    return obj;
  }

  @override
  void render(Canvas canvas, Offset location, TabletopController controller) {
    // Draw a stack
    canvas.drawRRect(
      RRect.fromLTRBR(
        location.dx,
        location.dy + 50,
        location.dx + size.width - 50,
        location.dy + 50 + size.height - 50,
        const Radius.circular(sectionSpacing * 2),
      ),
      Paint()..color = Get.theme.colorScheme.tertiary,
    );
    final rect = RRect.fromLTRBR(
      location.dx + 50,
      location.dy,
      location.dx + 50 + size.width - 50,
      location.dy + size.height - 50,
      const Radius.circular(sectionSpacing * 2),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Get.theme.colorScheme.onPrimary,
    );
    var textSpan = TextSpan(
      text: order.length.toString(),
      style: TextStyle(
        color: Get.theme.colorScheme.primary,
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
    textPainter.paint(canvas, Offset(rect.left + rect.width / 2 - textPainter.size.width / 2, rect.top + rect.height / 2 - textPainter.size.height / 2));
  }

  @override
  void handleData(String data) async {
    order.clear();
    cards.clear();
    final json = jsonDecode(data);
    final cardMap = json["cards"] as Map<String, dynamic>;
    for (var card in cardMap.values) {
      final type = await AttachmentController.checkLocations(card["id"], StorageType.cache);
      cards[card["id"]] = AttachmentContainer.fromJson(type, card);
    }
    order.addAll((json["order"] as List<dynamic>).cast<String>());
  }

  @override
  String getData() {
    final map = <String, dynamic>{};
    for (var card in cards.values) {
      map[card.id] = card.toJson();
    }

    return jsonEncode({
      "cards": map,
      "order": order.toList(),
    });
  }

  @override
  void runAction(TabletopController controller) {
    drawCard(controller);
  }

  /// Draw a card from the deck
  void drawCard(TabletopController controller) async {
    if (order.isEmpty) {
      return;
    }
    modify(() async {
      final cardId = order.removeAt(0);
      final container = cards[cardId]!;

      // Remove the card details if it isn't in the deck anymore
      if (!order.contains(cardId)) {
        cards.remove(cardId);
      }

      updateData();

      // Prepare the card and add it to the drop mode
      final card = await CardObject.downloadCard(container, controller.mousePos);
      if (card == null) return;
      controller.dropObject(card);
    });
  }

  /// Shuffle the deck
  void shuffle() {
    modify(() {
      order.shuffle();
      updateData();
    });
  }

  void addCard(CardObject obj) {
    modify(() {
      cards[obj.container.id] = obj.container;
      order.add(obj.container.id);
      obj.sendRemove();
      updateData();
    });
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.login,
        label: 'Draw into inventory',
        onTap: (controller) async {
          if (order.isEmpty) {
            return;
          }
          modify(() async {
            final cardId = order.removeAt(0);
            final container = cards[cardId]!;
            final obj = await CardObject.downloadCard(container, controller.mousePos);
            updateData();
            if (obj == null) return;
            obj.positionX.setRealValue(controller.mousePosUnmodified.dx - (obj.size.width / 2) * controller.canvasZoom);
            obj.positionY.setRealValue(controller.mousePosUnmodified.dy - (obj.size.height / 2) * controller.canvasZoom);
            controller.inventory.add(obj);
          });
        },
      ),
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

  void getDecksFromServer() async {
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
                    color: Get.theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: InkWell(
                      onTap: () {
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
