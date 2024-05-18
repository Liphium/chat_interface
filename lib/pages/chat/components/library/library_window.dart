import 'package:chat_interface/database/accounts/library_entry.dart';
import 'package:chat_interface/pages/chat/components/library/library_tab.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
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
  final _selected = "library.all".obs;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          //* Tabs
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SidebarButton(
                onTap: () => _selected.value = "library.all",
                radius: const BorderRadius.only(
                  bottomLeft: Radius.circular(defaultSpacing),
                ),
                label: "library.all",
                background: Get.theme.colorScheme.inverseSurface,
                selected: _selected,
              ),
              horizontalSpacing(elementSpacing),
              SidebarButton(
                onTap: () => _selected.value = "library.images",
                radius: const BorderRadius.only(),
                label: "library.images",
                background: Get.theme.colorScheme.inverseSurface,
                selected: _selected,
              ),
              horizontalSpacing(elementSpacing),
              SidebarButton(
                onTap: () => _selected.value = "library.gifs",
                radius: const BorderRadius.only(
                  topRight: Radius.circular(defaultSpacing),
                ),
                label: "library.gifs",
                background: Get.theme.colorScheme.inverseSurface,
                selected: _selected,
              ),
            ],
          ),
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: Obx(() {
                  switch (_selected.value) {
                    case "library.all":
                      return const LibraryTab();
                    case "library.images":
                      return const LibraryTab(filter: LibraryEntryType.image);
                    case "library.gifs":
                      return const LibraryTab(filter: LibraryEntryType.gif);
                  }
                  return const SizedBox();
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
