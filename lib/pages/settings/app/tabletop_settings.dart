import 'dart:io';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_decks.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/attachment_window.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopSettings {
  static const String framerate = "tabletop.framerate";

  // Experimental settings
  static const String smoothDragging = "tabletop.smooth_dragging";

  static void addSettings(SettingController controller) {
    controller.settings[framerate] = Setting<double>(framerate, 60.0);
    controller.settings[smoothDragging] = Setting<bool>(smoothDragging, false);
  }
}

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
    return SettingsPageBase(
      label: "tabletop",
      child: Column(
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
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Auto download types
        Text("tabletop.general.framerate".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
        DoubleSelectionSetting(
          settingName: TabletopSettings.framerate,
          description: "tabletop.general.framerate.description",
          unit: "tabletop.general.framerate.unit".tr,
          min: 30.0,
          max: 256.0,
          rounded: true,
        ),
        verticalSpacing(sectionSpacing),
        Row(
          children: [
            Text("tabletop.general.smooth_scrolling".tr, style: Get.theme.textTheme.labelLarge),
            horizontalSpacing(defaultSpacing),
          ],
        ),
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
        return Center(
          child: ErrorContainer(
            message: "settings.tabletop.decks.error".tr,
            expand: true,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Text(
                  "settings.tabletop.decks.limit".trParams({
                    "count": _decks.length.toString(),
                    "limit": Constants.maxDecks.toString(),
                  }),
                  style: Get.theme.textTheme.labelLarge,
                ),
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
                        Obx(
                          () => Text(
                            "decks.cards".trParams({"count": deck.cards.length.toString()}),
                            style: Get.theme.textTheme.bodyMedium,
                          ),
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
                          onTap: () => Get.dialog(DeckCardsWindow(deck: deck)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter, color: Get.theme.colorScheme.onPrimary),
                              horizontalSpacing(elementSpacing),
                              Text(
                                "decks.view_cards".tr,
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

/// Deck creation/edit window (only for name)
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

/// Deck cards window (for editing the cards of a deck)
class DeckCardsWindow extends StatefulWidget {
  final TabletopDeck deck;

  const DeckCardsWindow({
    super.key,
    required this.deck,
  });

  @override
  State<DeckCardsWindow> createState() => _DeckCardsWindowState();
}

class _DeckCardsWindowState extends State<DeckCardsWindow> {
  bool changed = false;

  @override
  void dispose() {
    if (changed) {
      widget.deck.save();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      maxWidth: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.deck.name, style: Get.theme.textTheme.titleLarge),
              FJElevatedButton(
                onTap: () async {
                  final result = await openFiles(acceptedTypeGroups: [
                    const XTypeGroup(label: "Image", extensions: FileSettings.staticImageTypes),
                  ]);
                  if (result.isEmpty) {
                    return;
                  }

                  // Check files
                  for (var file in result) {
                    if (await file.length() > 10 * 1000 * 1000) {
                      showErrorPopup("error".tr, "file.too_large".tr);
                      return;
                    }
                  }

                  final response = await Get.dialog(CardsUploadWindow(files: result), barrierDismissible: false);
                  if (response.isEmpty) {
                    showErrorPopup("error", "app.error");
                    return;
                  }

                  // Save to the vault
                  widget.deck.cards.addAll(response);

                  // Set the amount for all of them to 1
                  for (var card in response) {
                    widget.deck.amounts[card.id] = 1;
                  }

                  final res = await widget.deck.save();
                  if (!res) {
                    showErrorPopup("error", "server.error");
                    return;
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(elementSpacing),
                    Text(
                      "add".tr,
                      style: Get.theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(sectionSpacing),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 700),
              child: Obx(() {
                if (widget.deck.cards.isEmpty) {
                  return Text(
                    "decks.cards.empty".tr,
                    style: Get.theme.textTheme.bodyMedium,
                  );
                }

                return SingleChildScrollView(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200),
                    itemCount: widget.deck.cards.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final card = widget.deck.cards[index];
                      final file = File(widget.deck.cards[index].filePath);
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(elementSpacing),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              child: Image.file(file, width: 200, height: 200, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: defaultSpacing,
                            right: defaultSpacing,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(defaultSpacing),
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  widget.deck.cards.remove(card);
                                  Get.find<AttachmentController>().deleteFile(card);
                                  final result = await widget.deck.save();
                                  if (!result) {
                                    showErrorPopup("error", "server.error");
                                  }
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ),
                          ),
                          Positioned(
                            top: defaultSpacing,
                            left: defaultSpacing,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Get.theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(defaultSpacing),
                              ),
                              child: IconButton(
                                onPressed: () => Get.dialog(ImagePreviewWindow(file: file)),
                                icon: const Icon(Icons.launch),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: defaultSpacing),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Get.theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(defaultSpacing),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        changed = true;
                                        if ((widget.deck.amounts[card.id] ?? 1) == 1) {
                                          return;
                                        }
                                        widget.deck.amounts[card.id] = (widget.deck.amounts[card.id] ?? 1) - 1;
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    horizontalSpacing(elementSpacing),
                                    Obx(
                                      () => Text(
                                        widget.deck.amounts[card.id].toString(),
                                        style: Get.theme.textTheme.labelLarge,
                                      ),
                                    ),
                                    horizontalSpacing(elementSpacing),
                                    IconButton(
                                      onPressed: () async {
                                        changed = true;
                                        widget.deck.amounts[card.id] = (widget.deck.amounts[card.id] ?? 1) + 1;
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Cards upload window
class CardsUploadWindow extends StatefulWidget {
  final List<XFile> files;

  const CardsUploadWindow({super.key, required this.files});

  @override
  State<CardsUploadWindow> createState() => _CardsUploadWindowState();
}

class _CardsUploadWindowState extends State<CardsUploadWindow> {
  final _current = 0.obs;
  final finished = <AttachmentContainer>[];

  @override
  void initState() {
    startFileUploading();
    super.initState();
  }

  void startFileUploading() async {
    final controller = Get.find<AttachmentController>();
    _current.value = 0;
    for (var file in widget.files) {
      final response = await controller.uploadFile(UploadData(File(file.path)), StorageType.permanent, favorite: true);
      if (response.container == null) {
        Get.back(result: finished);
        showErrorPopup("error", response.message);
        return;
      }
      finished.add(response.container!);
      _current.value++;
    }

    Get.back(result: finished);
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Text(
                "file.uploading".trParams({
                  "index": (_current.value).toString(),
                  "total": widget.files.length.toString(),
                }),
                style: Get.theme.textTheme.titleLarge),
          ),
          verticalSpacing(sectionSpacing),
          Obx(
            () => LinearProgressIndicator(
              value: _current.value / widget.files.length,
              minHeight: 10,
              color: Get.theme.colorScheme.onPrimary,
              backgroundColor: Get.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
