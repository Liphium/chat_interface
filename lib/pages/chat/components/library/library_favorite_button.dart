import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/services/chat/library_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class LibraryFavoriteButton extends StatefulWidget {
  final AttachmentContainer container;
  final Widget child;
  final Function()? callback;
  final Function()? onEnter;
  final Function()? onExit;

  const LibraryFavoriteButton({
    super.key,
    required this.child,
    required this.container,
    this.callback,
    this.onEnter,
    this.onExit,
  });

  @override
  State<LibraryFavoriteButton> createState() => _LibraryFavoriteButtonState();
}

class _LibraryFavoriteButtonState extends State<LibraryFavoriteButton> with SignalsMixin {
  late final _visible = createSignal(false);
  late final _bookmarked = createSignal(false);
  LibraryEntry? _entry;

  /// Fetches the bookmark state from the local database
  Future<bool> fetchBookmarkState() async {
    // Find identifier for the entry
    final identifier = LibraryEntry.entryIdentifier(widget.container);

    // Check if there is an entry with this identifier
    final dbEntry =
        await (db.libraryEntry.select()..where((tbl) => tbl.identifierHash.equals(identifier)))
            .get();
    if (dbEntry.length > 1) {
      sendLog(
        "WARNING: hash collision with identifier of library entry, deleting all entries other than index 0",
      );
      for (var entry in dbEntry.sublist(1)) {
        await LibraryManager.removeEntryFromLibrary(await LibraryEntry.fromData(entry));
      }
    }
    _bookmarked.value = dbEntry.isNotEmpty;
    if (_bookmarked.value) {
      _entry = await LibraryEntry.fromData(dbEntry[0]);
    }

    // Just so you can await this function
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) async {
        await fetchBookmarkState();
        _visible.value = true;
        widget.onEnter?.call();
      },
      onExit: (e) {
        _visible.value = false;
        widget.onExit?.call();
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: elementSpacing,
            right: elementSpacing,
            child: Watch(
              (ctx) => Visibility(
                visible: _visible.value,
                child: Material(
                  color: Get.theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(elementSpacing),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                    onTap: () async {
                      if (_bookmarked.value) {
                        final success = await LibraryManager.removeEntryFromLibrary(_entry!);
                        if (success) {
                          _bookmarked.value = false;
                        }
                      } else {
                        final success = await LibraryManager.addContainerToLibrary(
                          widget.container,
                        );
                        if (success) {
                          _bookmarked.value = true;
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(elementSpacing),
                      child: Watch(
                        (ctx) => Icon(
                          _bookmarked.value ? Icons.bookmark : Icons.bookmark_outline,
                          color:
                              _bookmarked.value
                                  ? Get.theme.colorScheme.onPrimary
                                  : Get.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
