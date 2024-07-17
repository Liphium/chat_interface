import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/components/library/library_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryFavoriteButton extends StatefulWidget {
  final AttachmentContainer container;
  final Widget child;
  final Function()? callback;

  const LibraryFavoriteButton({
    super.key,
    required this.child,
    required this.container,
    this.callback,
  });

  @override
  State<LibraryFavoriteButton> createState() => _LibraryFavoriteButtonState();
}

class _LibraryFavoriteButtonState extends State<LibraryFavoriteButton> {
  final visible = false.obs;
  final bookmarked = false.obs;

  void fetchBookmarkState() async {
    if (widget.container.attachmentType == AttachmentContainerType.remoteImage) {
      bookmarked.value = await (db.libraryEntry.select()..where((tbl) => tbl.data.equals(widget.container.url))).getSingleOrNull() != null;
    } else {
      bookmarked.value = await (db.libraryEntry.select()..where((tbl) => tbl.data.contains(widget.container.id))).getSingleOrNull() != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) {
        fetchBookmarkState();
        visible.value = true;
      },
      onExit: (e) => visible.value = false,
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
                  color: Get.theme.colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(elementSpacing),
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                    onTap: () async {
                      // TODO: Reimplement
                      /*
                      final entry = await LibraryManager.getFromContainer(widget.container);
                      if (entry == null) {
                        return;
                      }
                      widget.callback?.call();
                      if (bookmarked.value) {
                        await db.libraryEntry.deleteWhere((tbl) => tbl.data.equals(entry.data));
                        bookmarked.value = false;
                        return;
                      }
                      await db.libraryEntry.insertOne(entry);
                      bookmarked.value = true;
                      */
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
