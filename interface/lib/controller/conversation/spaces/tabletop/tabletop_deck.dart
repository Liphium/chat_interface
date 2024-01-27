import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_decks.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeckObject extends TableObject {
  /// Card ID -> Amount in deck
  final amount = <String, int>{};

  /// Card ID -> Card data
  final cards = <String, AttachmentContainer>{};

  DeckObject(super.id, super.location, super.size, super.type);

  @override
  void render(Canvas canvas, Offset location, TabletopController controller) {
    // Draw a stack
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(location.dx, location.dy, size.width, size.height), paint);
  }

  @override
  void importData(String data) {}

  @override
  void runAction(TabletopController controller) {
    sendLog("this is an action");
  }

  @override
  List<ContextMenuAction> getContextMenuAdditions() {
    return [
      ContextMenuAction(
        icon: Icons.shuffle,
        label: 'Shuffle',
        onTap: (controller) {},
      ),
    ];
  }
}

class DeckObjectCreationWindow extends StatefulWidget {
  const DeckObjectCreationWindow({super.key});

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

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choose a deck".tr, style: Get.theme.textTheme.titleMedium),
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
                      onTap: () => {},
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
