import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/database/database_entities.dart';
import 'package:chat_interface/pages/chat/components/library/library_tab.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class LibraryWindow extends StatefulWidget {
  final ContextMenuData data;
  final MessageProvider provider;

  const LibraryWindow({
    super.key,
    required this.data,
    required this.provider,
  });

  @override
  State<LibraryWindow> createState() => _LibraryWindowState();
}

class _LibraryWindowState extends State<LibraryWindow> {
  final _selected = signal("library.all".tr);

  var _tabs = <String, Widget>{};

  @override
  void didUpdateWidget(covariant LibraryWindow oldWidget) {
    _tabs = <String, Widget>{
      'library.all'.tr: LibraryTab(provider: widget.provider),
      'library.images'.tr: LibraryTab(filter: LibraryEntryType.image, provider: widget.provider),
      'library.gifs'.tr: LibraryTab(filter: LibraryEntryType.gif, provider: widget.provider),
    };
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _tabs = <String, Widget>{
      'library.all'.tr: LibraryTab(provider: widget.provider),
      'library.images'.tr: LibraryTab(filter: LibraryEntryType.image, provider: widget.provider),
      'library.gifs'.tr: LibraryTab(filter: LibraryEntryType.gif, provider: widget.provider),
    };
    super.initState();
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
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
                child: Watch((ctx) {
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
