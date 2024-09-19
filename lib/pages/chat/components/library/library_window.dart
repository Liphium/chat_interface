import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/pages/chat/components/library/library_tab.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryWindow extends StatefulWidget {
  final ContextMenuData data;

  const LibraryWindow({super.key, required this.data});

  @override
  State<LibraryWindow> createState() => _LibraryWindowState();
}

class _LibraryWindowState extends State<LibraryWindow> {
  final _selected = "library.all".tr.obs;

  final _tabs = <String, Widget>{
    'library.all'.tr: const LibraryTab(),
    'library.images'.tr: const LibraryTab(filter: LibraryEntryType.image),
    'library.gifs'.tr: const LibraryTab(filter: LibraryEntryType.gif),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      title: const [],
      maxSize: 500,
      position: widget.data,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          //* Tabs
          LPHTabElement(
            tabs: [
              "library.all".tr,
              "library.images".tr,
              "library.gifs".tr,
            ],
            onTabSwitch: (newTab) {
              _selected.value = newTab;
            },
          ),
          verticalSpacing(elementSpacing),
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: Obx(() {
                  return _tabs[_selected.value]!;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
