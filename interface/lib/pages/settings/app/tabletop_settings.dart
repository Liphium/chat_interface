import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_decks.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopSettingsPage extends StatefulWidget {
  const TabletopSettingsPage({super.key});

  @override
  State<TabletopSettingsPage> createState() => _TabletopSettingsPageState();
}

class _TabletopSettingsPageState extends State<TabletopSettingsPage> {
  final _selected = "settings.tabletop.general".obs;

  // Tabs
  final _tabs = <String, Widget>{
    "settings.tabletop.general": const TabletopGeneralTab(),
    "settings.tabletop.decks": const TabletopDeckTab(),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Tabs
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SidebarButton(
            onTap: () => _selected.value = "settings.tabletop.general",
            radius: const BorderRadius.only(
              bottomLeft: Radius.circular(defaultSpacing),
            ),
            label: "settings.tabletop.general",
            selected: _selected,
          ),
          horizontalSpacing(elementSpacing),
          SidebarButton(
            onTap: () => _selected.value = "settings.tabletop.decks",
            radius: const BorderRadius.only(
              topRight: Radius.circular(defaultSpacing),
            ),
            label: "settings.tabletop.decks",
            selected: _selected,
          )
        ]),

        verticalSpacing(sectionSpacing),

        //* Current tab
        Obx(() => _tabs[_selected.value]!)
      ],
    );
  }
}

class TabletopGeneralTab extends StatefulWidget {
  const TabletopGeneralTab({super.key});

  @override
  State<TabletopGeneralTab> createState() => _TabletopGeneralTabState();
}

class _TabletopGeneralTabState extends State<TabletopGeneralTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* Auto download types
        Text("Some tabletop settings go here".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
      ],
    );
  }
}

class TabletopDeckTab extends StatefulWidget {
  const TabletopDeckTab({super.key});

  @override
  State<TabletopDeckTab> createState() => _TabletopDeckTabState();
}

class _TabletopDeckTabState extends State<TabletopDeckTab> {
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
    return Obx(() {
      if (_loading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: Get.theme.colorScheme.onPrimary,
          ),
        );
      }

      if (_error.value) {
        return Center(child: ErrorContainer(message: "settings.tabletop.decks.error".tr));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "settings.tabletop.decks.limit".trParams({
                  "count": _decks.length.toString(),
                  "limit": Constants.maxDecks.toString(),
                }),
                style: Get.theme.textTheme.labelLarge,
              ),
              FJElevatedButton(
                onTap: () async {
                  if (_decks.length >= Constants.maxDecks) {
                    showErrorPopup("error", "decks.limit_reached");
                    return;
                  }
                  final result = await Get.dialog(const DeckCreationWindow());
                  if (result is TabletopDeck) {
                    _decks.add(result);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(elementSpacing),
                    Text(
                      "decks.create".tr,
                      style: Get.theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(defaultSpacing),
          Text("decks.description".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(sectionSpacing),
          ListView.builder(
            itemCount: _decks.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final deck = _decks[index];
              return Container(
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                ),
                margin: const EdgeInsets.only(bottom: defaultSpacing),
                padding: const EdgeInsets.all(sectionSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deck.name, style: Get.theme.textTheme.labelLarge),
                        verticalSpacing(elementSpacing),
                        Text(
                          "decks.cards".trParams({"count": deck.cards.length.toString()}),
                          style: Get.theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.dialog(DeckCreationWindow(deck: deck)).then((value) {
                              if (value is TabletopDeck) {
                                deck.name = value.name;
                                _loading.value = true;
                                _loading.value = false;
                              }
                            });
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        horizontalSpacing(elementSpacing),
                        IconButton(
                          onPressed: () => showConfirmPopup(ConfirmWindow(
                            title: "decks.dialog.delete.title".tr,
                            text: "decks.dialog.delete".tr,
                            onConfirm: () async {
                              final res = await deck.delete();
                              if (res) {
                                _decks.remove(deck);
                              }
                            },
                          )),
                          icon: const Icon(Icons.delete),
                        ),
                        horizontalSpacing(defaultSpacing),
                        FJElevatedButton(
                          onTap: () async {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_to_photos, color: Get.theme.colorScheme.onPrimary),
                              horizontalSpacing(elementSpacing),
                              Text(
                                "decks.add_cards".tr,
                                style: Get.theme.textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ],
      );
    });
  }
}

class DeckCreationWindow extends StatefulWidget {
  final TabletopDeck? deck;

  const DeckCreationWindow({super.key, this.deck});

  @override
  State<DeckCreationWindow> createState() => _DeckCreationWindowState();
}

class _DeckCreationWindowState extends State<DeckCreationWindow> {
  final TextEditingController _nameController = TextEditingController();
  final _errorText = "".obs;
  final _loading = false.obs;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.deck?.name ?? "";
    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.deck == null ? "decks.dialog.name".tr : "decks.dialog.new_name".tr, style: Get.theme.textTheme.bodyMedium),
          verticalSpacing(sectionSpacing),
          FJTextField(
            hintText: "decks.dialog.name.placeholder".tr,
            controller: _nameController,
            maxLength: Constants.normalNameLimit,
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            message: _errorText,
            expand: true,
          ),
          FJElevatedLoadingButtonCustom(
            loading: _loading,
            onTap: () async {
              _loading.value = true;
              _errorText.value = "";
              if (_nameController.text.length < 3) {
                _errorText.value = "decks.dialog.name.error".tr;
                _loading.value = false;
                return;
              }

              if (widget.deck != null) {
                widget.deck!.name = _nameController.text;
                final res = await widget.deck!.save();
                if (res) {
                  Get.back(result: widget.deck);
                }
                return;
              } else {
                final deck = TabletopDeck(_nameController.text);
                final res = await deck.save();
                if (res) {
                  Get.back(result: deck);
                }
              }
            },
            builder: () => Center(
              child: SizedBox(
                height: Get.theme.textTheme.labelLarge!.fontSize! + defaultSpacing,
                width: Get.theme.textTheme.labelLarge!.fontSize! + defaultSpacing,
                child: Padding(
                  padding: const EdgeInsets.all(defaultSpacing * 0.25),
                  child: CircularProgressIndicator(strokeWidth: 3.0, color: Get.theme.colorScheme.onPrimary),
                ),
              ),
            ),
            child: Center(
              child: Text(widget.deck == null ? "create".tr : "save".tr, style: Get.theme.textTheme.labelLarge),
            ),
          ),
        ],
      ),
    );
  }
}
