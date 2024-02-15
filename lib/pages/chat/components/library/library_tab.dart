import 'package:chat_interface/database/accounts/library_entry.dart';
import 'package:chat_interface/database/database.dart';
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
  final entryList = <LibraryEntryData>[].obs;

  @override
  void initState() {
    super.initState();
    loadMoreItems();
  }

  void loadMoreItems() async {
    final lastTime = entryList.isEmpty ? BigInt.from(0) : entryList.last.createdAt;
    List<LibraryEntryData> entries;
    if (widget.filter != null) {
      entries = await (db.libraryEntry.select()
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
            ..where((tbl) => tbl.createdAt.isSmallerThan(Variable(lastTime)))
            ..where((tbl) => tbl.type.equals(widget.filter!.index))
            ..limit(30))
          .get();
    } else {
      entries = await (db.libraryEntry.select()
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
            ..where((tbl) => tbl.createdAt.isSmallerThan(Variable(lastTime)))
            ..limit(30))
          .get();
    }
    entryList.addAll(entries);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (entryList.isEmpty) {
        return InfoContainer(
          message: "library.empty".tr,
          expand: true,
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        itemCount: entryList.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: defaultSpacing,
          crossAxisSpacing: defaultSpacing,
        ),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.red,
          );
        },
      );
    });
  }
}
