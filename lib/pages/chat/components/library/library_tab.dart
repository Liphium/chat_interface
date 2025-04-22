import 'dart:async';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/components/library/library_favorite_button.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/services/chat/library_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liphium_bridge/liphium_bridge.dart';
import 'package:signals/signals_flutter.dart';

class LibraryTab extends StatefulWidget {
  final model.LibraryEntryType? filter;
  final MessageProvider provider;

  const LibraryTab({super.key, this.filter, required this.provider});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  model.LibraryEntryType? _lastFilter;
  final _entryList = listSignal(<LibraryEntry>[]);
  BigInt _lastDate = BigInt.from(0);
  final _show = signal(false);

  @override
  void dispose() {
    _show.dispose();
    _entryList.dispose();
    super.dispose();
  }

  Future<void> loadMoreItems() async {
    // Make sure to start from the top again when a new filter is set
    if (widget.filter != _lastFilter) {
      _lastDate = BigInt.from(0);
    }

    // Get all the library entries that match the current filter
    List<LibraryEntryData> entries;
    if (widget.filter != null) {
      entries =
          await (db.libraryEntry.select()
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
                ..where((tbl) => tbl.createdAt.isBiggerThan(Variable(_lastDate)))
                ..where((tbl) => tbl.type.equals(widget.filter!.index))
                ..limit(30))
              .get();
    } else {
      entries =
          await (db.libraryEntry.select()
                ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
                ..where((tbl) => tbl.createdAt.isBiggerThan(Variable(_lastDate)))
                ..limit(30))
              .get();
    }
    if (entries.isNotEmpty) {
      _lastDate = entries.last.createdAt;
    }

    // Get all the attachment containers from the library entries for displaying them
    final newEntryList = <LibraryEntry>[];
    for (var dbEntry in entries) {
      final entry = await LibraryEntry.fromData(dbEntry);
      await entry.initForUI();
      newEntryList.add(entry);
    }

    // Add the containers to the list of entries
    if (_lastFilter != widget.filter) {
      _entryList.value = newEntryList;
    } else {
      _entryList.addAll(newEntryList);
    }

    // Set what's nessecary for the next iteration
    _lastFilter = widget.filter;
    _show.value = true;
  }

  @override
  Widget build(BuildContext context) {
    unawaited(loadMoreItems());

    return Watch((ctx) {
      if (!_show.value) {
        return const SizedBox();
      }

      if (_entryList.isEmpty) {
        return InfoContainer(message: "library.empty".tr, expand: true);
      }

      return GridView.builder(
        shrinkWrap: true,
        itemCount: _entryList.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: defaultSpacing,
          crossAxisSpacing: defaultSpacing,
        ),
        itemBuilder: (context, index) {
          final entry = _entryList[index];
          entry.container!.downloaded.value = true;

          // Render attachment container
          Widget image;
          if (entry.container!.attachmentType == AttachmentContainerType.remoteImage) {
            image = Image.network(entry.container!.url, fit: BoxFit.cover);
          } else {
            image = XImage(file: entry.container!.file!, fit: BoxFit.cover);
          }
          return Material(
            key: ValueKey(entry.container!.id),
            borderRadius: BorderRadius.circular(defaultSpacing),
            child: InkWell(
              borderRadius: BorderRadius.circular(defaultSpacing),
              onTap: () {
                //* Send message with the library element
                widget.provider.sendMessage(signal(false), MessageType.text, [entry.container!.toAttachment()], "", "");
                Get.back();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(defaultSpacing),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return LibraryFavoriteButton(
                      callback: () => _entryList.removeAt(index),
                      container: entry.container!,
                      child: SizedBox(
                        width: constraints.biggest.width,
                        height: constraints.biggest.height,
                        child: image,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
