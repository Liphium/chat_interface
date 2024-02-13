import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryWindow extends StatefulWidget {
  const LibraryWindow({super.key});

  @override
  State<LibraryWindow> createState() => _LibraryWindowState();
}

class _LibraryWindowState extends State<LibraryWindow> {
  final _selected = "library.all".obs;

  // Tabs
  final _tabs = <String, Widget>{
    "library.all": const Placeholder(),
    "library.images": const Placeholder(),
    "library.gifs": const Placeholder(),
  };

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      maxWidth: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //* Search box
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(defaultSpacing * 1.5),
                    ),
                    color: Get.theme.colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                      child: TextField(
                        style: Get.theme.textTheme.labelMedium,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusColor: Get.theme.colorScheme.onPrimary,
                          iconColor: Get.theme.colorScheme.onPrimary,
                          fillColor: Get.theme.colorScheme.onPrimary,
                          hoverColor: Get.theme.colorScheme.onPrimary,
                          prefixIcon: Icon(Icons.search, color: Get.theme.colorScheme.onPrimary),
                          hintText: "conversations.placeholder".tr,
                        ),
                        onChanged: (value) {},
                        cursorColor: Get.theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                horizontalSpacing(elementSpacing),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(defaultSpacing * 1.5),
                    ),
                    color: Get.theme.colorScheme.primary,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(defaultSpacing),
                      ),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Icon(Icons.file_upload, color: Get.theme.colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),

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
                background: Get.theme.colorScheme.background,
                selected: _selected,
              ),
              horizontalSpacing(elementSpacing),
              SidebarButton(
                onTap: () => _selected.value = "library.images",
                radius: const BorderRadius.only(),
                label: "library.images",
                background: Get.theme.colorScheme.background,
                selected: _selected,
              ),
              horizontalSpacing(elementSpacing),
              SidebarButton(
                onTap: () => _selected.value = "library.gifs",
                radius: const BorderRadius.only(
                  topRight: Radius.circular(defaultSpacing),
                ),
                label: "library.gifs",
                background: Get.theme.colorScheme.background,
                selected: _selected,
              )
            ],
          ),
        ],
      ),
    );
  }
}
