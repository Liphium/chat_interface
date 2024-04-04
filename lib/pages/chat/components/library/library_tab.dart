import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/database/accounts/library_entry.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/chat/components/library/library_favorite_button.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryTab extends StatefulWidget {
  final LibraryEntryType? filter;

  const LibraryTab({
    super.key,
    this.filter,
  });

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  LibraryEntryType? _lastFilter;
  final _containerList = <AttachmentContainer>[].obs;
  BigInt lastDate = BigInt.from(0);
  final _show = false.obs;

  void loadMoreItems() async {
    if (widget.filter != _lastFilter) {
      lastDate = BigInt.from(0);
    }
    List<LibraryEntryData> entries;
    if (widget.filter != null) {
      entries = await (db.libraryEntry.select()
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
            ..where((tbl) => tbl.createdAt.isBiggerThan(Variable(lastDate)))
            ..where((tbl) => tbl.type.equals(widget.filter!.index))
            ..limit(30))
          .get();
    } else {
      entries = await (db.libraryEntry.select()
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])
            ..where((tbl) => tbl.createdAt.isBiggerThan(Variable(lastDate)))
            ..limit(30))
          .get();
    }
    if (entries.isNotEmpty) {
      lastDate = entries.last.createdAt;
    }
    final newContainerList = <AttachmentContainer>[];
    for (var entry in entries) {
      if (entry.data.isURL) {
        newContainerList.add(AttachmentContainer.remoteImage(entry.data));
      } else {
        final json = jsonDecode(entry.data);
        final type = await AttachmentController.getStorageTypeFor(json["id"]);
        if (type == null) {
          continue;
        }
        newContainerList.add(AttachmentContainer.fromJson(type, json));
      }
    }
    if (_lastFilter != widget.filter) {
      _containerList.value = newContainerList;
    } else {
      _containerList.addAll(newContainerList);
    }
    _lastFilter = widget.filter;
    _show.value = true;
  }

  @override
  Widget build(BuildContext context) {
    loadMoreItems();

    return Obx(() {
      if (!_show.value) {
        return const SizedBox();
      }

      if (_containerList.isEmpty) {
        return InfoContainer(
          message: "library.empty".tr,
          expand: true,
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        itemCount: _containerList.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: defaultSpacing,
          crossAxisSpacing: defaultSpacing,
        ),
        itemBuilder: (context, index) {
          final container = _containerList[index];
          container.downloaded.value = true;

          // Render attachment container
          Image image;
          if (container.attachmentType == AttachmentContainerType.remoteImage) {
            image = Image.network(
              container.url,
              fit: BoxFit.cover,
            );
          } else {
            image = Image.file(
              File(container.filePath),
              fit: BoxFit.cover,
            );
          }
          return Material(
            key: ValueKey(container.id),
            borderRadius: BorderRadius.circular(defaultSpacing),
            child: InkWell(
              borderRadius: BorderRadius.circular(defaultSpacing),
              onTap: () {
                //* Send message with the library element
                final controller = Get.find<MessageController>();
                if (controller.selectedConversation.value.id == "") {
                  return;
                }
                sendActualMessage(false.obs, controller.selectedConversation.value.id, MessageType.text, [container.toAttachment()], "", "", () => {});
                Get.back();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(defaultSpacing),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return LibraryFavoriteButton(
                      callback: () => _containerList.removeAt(index),
                      container: container,
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
