import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/components/library/library_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class _LibraryFavoriteButtonState extends State<LibraryFavoriteButton> {
  final visible = false.obs;
  final bookmarked = false.obs;
  LibraryEntry? entry;

  /// Fetches the bookmark state from the local database
  Future<bool> fetchBookmarkState() async {
    if (widget.container.attachmentType == AttachmentContainerType.remoteImage) {
      final dbEntry = await (db.libraryEntry.select()..where((tbl) => tbl.data.equals(widget.container.url))).getSingleOrNull();
      bookmarked.value = dbEntry != null;
      if (bookmarked.value) {
        entry = LibraryEntry.fromData(dbEntry!);
      }
    } else {
      final dbEntry = await (db.libraryEntry.select()..where((tbl) => tbl.data.contains(widget.container.id))).getSingleOrNull();
      bookmarked.value = dbEntry != null;
      if (bookmarked.value) {
        entry = LibraryEntry.fromData(dbEntry!);
      }
    }

    // Just so you can await this function
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) async {
        await fetchBookmarkState();
        visible.value = true;
        widget.onEnter?.call();
      },
      onExit: (e) {
        visible.value = false;
        widget.onExit?.call();
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: elementSpacing,
            right: elementSpacing,
            child: Obx(
              () => Visibility(
                visible: visible.value,
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
                      if (bookmarked.value) {
                        final success = await LibraryManager.removeEntryFromLibrary(entry!);
                        if (success) {
                          bookmarked.value = false;
                        }
                      } else {
                        final success = await LibraryManager.addContainerToLibrary(widget.container);
                        if (success) {
                          bookmarked.value = true;
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(elementSpacing),
                      child: Obx(
                        () => Icon(
                          bookmarked.value ? Icons.bookmark : Icons.bookmark_outline,
                          color: bookmarked.value ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
