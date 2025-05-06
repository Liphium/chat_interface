import 'dart:async';
import 'dart:math';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_decks.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_zap_renderer.dart';
import 'package:chat_interface/pages/settings/town/file_settings.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/image_preview_window.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;
import 'package:liphium_bridge/liphium_bridge.dart';
import 'package:signals/signals_flutter.dart';

class TabletopSettings {
  static const String framerate = "tabletop.framerate";
  static const String cursorHue = "tabletop.cursor_hue";

  // Experimental settings
  static const String smoothDragging = "tabletop.smooth_dragging";

  static void addSettings() {
    SettingController.addSetting(Setting<double>(framerate, 60.0));
    SettingController.addSetting(Setting<double>(cursorHue, 0.0));

    // I don't know if we will ever do this xd
    SettingController.addSetting(Setting<bool>(smoothDragging, false));
  }

  /// Initialize the cursor hue to make sure it's actually randomized by default
  static Future<void> initSettings() async {
    final val = await (db.setting.select()..where((tbl) => tbl.key.equals(cursorHue))).getSingleOrNull();
    if (val == null) {
      await SettingController.settings[cursorHue]!.setValue(Random().nextDouble());
    }
  }

  static Color getCursorColor({double? hue}) {
    final themeHSL = HSLColor.fromColor(Get.theme.colorScheme.onPrimary);
    hue ??= SettingController.settings[cursorHue]!.getValue();
    return HSLColor.fromAHSL(1.0, hue! * 360, themeHSL.saturation, themeHSL.lightness).toColor();
  }

  static double getHue() {
    return SettingController.settings[cursorHue]!.getValue();
  }
}

class TabletopSettingsPage extends StatefulWidget {
  const TabletopSettingsPage({super.key});

  @override
  State<TabletopSettingsPage> createState() => _TabletopSettingsPageState();
}

class _TabletopSettingsPageState extends State<TabletopSettingsPage> with SignalsMixin {
  late final _selected = createSignal("settings.tabletop.general".tr);

  // Tabs
  final _tabs = <String, Widget>{
    "settings.tabletop.general".tr: const TabletopGeneralTab(),
    "settings.tabletop.decks".tr: const TabletopDeckTab(),
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
          LPHTabElement(
            tabs: _tabs.keys.toList(),
            onTabSwitch: (tab) {
              _selected.value = tab;
            },
          ),
          verticalSpacing(sectionSpacing),

          //* Current tab
          _tabs[_selected.value]!,
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
  /// The hue of the cursor (for updating the preview)
  final _cursorHue = signal(0.0);

  @override
  void initState() {
    _cursorHue.value = SettingController.settings[TabletopSettings.cursorHue]!.getValue();
    super.initState();
  }

  @override
  void dispose() {
    _cursorHue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Framerate of the table
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

        //* The color of the cursor on tabletop
        Text("tabletop.general.color".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
        Text("tabletop.general.color.description".tr, style: Get.theme.textTheme.bodyMedium),
        verticalSpacing(defaultSpacing),
        Row(
          children: [
            SizedBox(
              width: 45,
              height: 45,
              child: Stack(
                children: [
                  Watch(
                    (ctx) => Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: TabletopSettings.getCursorColor(hue: _cursorHue.value),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Align(alignment: Alignment.center, child: UserAvatar(id: StatusController.ownAddress, size: 40)),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Watch(
                      (ctx) => Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: TabletopSettings.getCursorColor(hue: _cursorHue.value),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            horizontalSpacing(sectionSpacing),
            Expanded(
              child: DoubleSelectionSetting(
                settingName: TabletopSettings.cursorHue,
                description: "",
                min: 0.0,
                max: 1.0,
                onChange: (val) {
                  _cursorHue.value = val;
                },
              ),
            ),
          ],
        ),
        verticalSpacing(sectionSpacing),
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
  final _decks = listSignal<TabletopDeck>([]);
  final _loading = signal(true);
  final _error = signal(false);

  @override
  void dispose() {
    _decks.dispose();
    _loading.dispose();
    _error.dispose();
    super.dispose();
  }

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
    return Watch((ctx) {
      if (_loading.value) {
        return Center(child: CircularProgressIndicator(color: Get.theme.colorScheme.onPrimary));
      }

      if (_error.value) {
        return Center(child: ErrorContainer(message: "settings.tabletop.decks.error".tr, expand: true));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Watch(
                (ctx) => Text(
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
                    showErrorPopup("error", "decks.limit_reached".tr);
                    return;
                  }
                  final result = await showModal(const DeckCreationWindow());
                  if (result is TabletopDeck) {
                    _decks.add(result);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(elementSpacing),
                    Text("decks.create".tr, style: Get.theme.textTheme.labelLarge),
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
                  color: Get.theme.colorScheme.onInverseSurface,
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
                        Watch(
                          (context) => Text(
                            "decks.cards".trParams({"count": deck.cards.value.length.toString()}),
                            style: Get.theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showModal(DeckCreationWindow(deck: deck))?.then((value) {
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
                          onPressed:
                              () => showConfirmPopup(
                                ConfirmWindow(
                                  title: "decks.dialog.delete.title".tr,
                                  text: "decks.dialog.delete".tr,
                                  onConfirm: () async {
                                    final res = await deck.delete();
                                    if (res) {
                                      _decks.remove(deck);
                                    }
                                  },
                                ),
                              ),
                          icon: const Icon(Icons.delete),
                        ),
                        horizontalSpacing(defaultSpacing),
                        FJElevatedButton(
                          onTap: () => showModal(DeckCardsWindow(deck: deck)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.filter, color: Get.theme.colorScheme.onPrimary),
                              horizontalSpacing(elementSpacing),
                              Text("decks.view_cards".tr, style: Get.theme.textTheme.labelLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
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
  final _errorText = signal("");
  final _loading = signal(false);

  @override
  void dispose() {
    _errorText.dispose();
    _loading.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> createDeck() async {
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
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.deck?.name ?? "";
    return DialogBase(
      title: const [],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.deck == null ? "decks.dialog.name".tr : "decks.dialog.new_name".tr,
            style: Get.theme.textTheme.bodyMedium,
          ),
          verticalSpacing(sectionSpacing),
          FJTextField(
            hintText: "decks.dialog.name.placeholder".tr,
            controller: _nameController,
            maxLength: Constants.normalNameLimit,
            autofocus: true,
            onSubmitted: (t) => createDeck(),
          ),
          verticalSpacing(defaultSpacing),
          AnimatedErrorContainer(
            padding: const EdgeInsets.only(bottom: defaultSpacing),
            message: _errorText,
            expand: true,
          ),
          FJElevatedLoadingButtonCustom(
            loading: _loading,
            onTap: () => createDeck(),
            builder:
                () => Center(
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

  const DeckCardsWindow({super.key, required this.deck});

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
      title: const [],
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
                  final result = await openFiles(
                    acceptedTypeGroups: [const XTypeGroup(label: "Image", extensions: FileSettings.staticImageTypes)],
                  );
                  if (result.isEmpty) {
                    return;
                  }

                  // Check files
                  for (var file in result) {
                    if (await file.length() > specialConstants[Constants.specialConstantMaxFileSize]!) {
                      showErrorPopup(
                        "error",
                        "file.too_large".trParams({
                          "1": formatFileSize(specialConstants[Constants.specialConstantMaxFileSize]!),
                        }),
                      );
                      return;
                    }
                  }

                  final response = await Get.dialog(CardsUploadWindow(files: result), barrierDismissible: false);
                  if (response.isEmpty) {
                    showErrorPopupTranslated("error", "app.error".tr);
                    return;
                  }

                  // Save to the vault
                  widget.deck.cards.value.addAll(response);

                  // Set the amount for all of them to 1
                  for (var card in response) {
                    widget.deck.amounts.value[card.id] = 1;
                  }

                  final res = await widget.deck.save();
                  if (!res) {
                    showErrorPopupTranslated("error", "server.error".tr);
                    return;
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                    horizontalSpacing(elementSpacing),
                    Text("add".tr, style: Get.theme.textTheme.labelLarge),
                  ],
                ),
              ),
            ],
          ),
          verticalSpacing(sectionSpacing),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 700),
              child: Watch((context) {
                if (widget.deck.cards.value.isEmpty) {
                  return Text("decks.cards.empty".tr, style: Get.theme.textTheme.bodyMedium);
                }

                return SingleChildScrollView(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200),
                    itemCount: widget.deck.cards.value.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final card = widget.deck.cards.value[index];
                      final file = widget.deck.cards.value[index].file!;
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(elementSpacing),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              child: XImage(file: file, width: 200, height: 200, fit: BoxFit.cover),
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
                                  widget.deck.cards.value.remove(card);
                                  unawaited(AttachmentController.deleteFile(card));
                                  final result = await widget.deck.save();
                                  if (!result) {
                                    showErrorPopup("error", "server.error".tr);
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
                                onPressed: () {
                                  sendLog(card.width);
                                  Get.dialog(ImagePreviewWindow(file: file));
                                },
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
                                        if ((widget.deck.amounts.value[card.id] ?? 1) == 1) {
                                          return;
                                        }
                                        widget.deck.amounts.value[card.id] =
                                            (widget.deck.amounts.value[card.id] ?? 1) - 1;
                                      },
                                      icon: const Icon(Icons.remove),
                                    ),
                                    horizontalSpacing(elementSpacing),
                                    Watch(
                                      (context) => Text(
                                        widget.deck.amounts.value[card.id].toString(),
                                        style: Get.theme.textTheme.labelLarge,
                                      ),
                                    ),
                                    horizontalSpacing(elementSpacing),
                                    IconButton(
                                      onPressed: () async {
                                        changed = true;
                                        widget.deck.amounts.value[card.id] =
                                            (widget.deck.amounts.value[card.id] ?? 1) + 1;
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

class _CardsUploadWindowState extends State<CardsUploadWindow> with SignalsMixin {
  late final _current = createSignal(0);
  final finished = <AttachmentContainer>[];

  @override
  void initState() {
    startFileUploading();
    super.initState();
  }

  Future<void> startFileUploading() async {
    _current.value = 0;
    for (var file in widget.files) {
      // Upload the card to the server
      final response = await AttachmentController.uploadFile(
        UploadData(file),
        StorageType.permanent,
        Constants.fileDeckTag,
        containerNameNull: true,
      );
      if (response.container == null) {
        Get.back(result: finished);
        showErrorPopup("error", response.message);
        return;
      }

      // Precalculate the width and height of the card (part of the new standard)
      await response.container!.precalculateWidthAndHeight();
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
          Text(
            "file.uploading".trParams({"index": (_current.value).toString(), "total": widget.files.length.toString()}),
            style: Get.theme.textTheme.titleLarge,
          ),
          verticalSpacing(sectionSpacing),
          LinearProgressIndicator(
            value: _current.value / widget.files.length,
            minHeight: 10,
            color: Get.theme.colorScheme.onPrimary,
            backgroundColor: Get.theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
