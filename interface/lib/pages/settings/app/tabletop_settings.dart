import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabletopSettingsPage extends StatefulWidget {
  const TabletopSettingsPage({super.key});

  @override
  State<TabletopSettingsPage> createState() => _TabletopSettingsPageState();
}

class _TabletopSettingsPageState extends State<TabletopSettingsPage> {
  final _selected = "settings.tabletop.general".obs;

  // Tabs
  final _tabs = <String, Widget>{
    "settings.tabletop.general": const TabletopDeckTab(),
    "settings.tabletop.decks": const TabletopDeckTab(),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Tabs
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SidebarButton(
            onTap: () => _selected.value = "settings.tabletop.general",
            radius: const BorderRadius.only(
              bottomLeft: Radius.circular(defaultSpacing),
            ),
            label: "settings.tabletop.general",
            selected: _selected,
          ),
          horizontalSpacing(elementSpacing),
          SidebarButton(
            onTap: () => _selected.value = "settings.tabletop.decks",
            radius: const BorderRadius.only(
              topRight: Radius.circular(defaultSpacing),
            ),
            label: "settings.tabletop.decks",
            selected: _selected,
          )
        ]),

        verticalSpacing(sectionSpacing),

        //* Current tab
        Obx(() => _tabs[_selected.value]!)
      ],
    );
  }
}

class TabletopGeneralTab extends StatefulWidget {
  const TabletopGeneralTab({super.key});

  @override
  State<TabletopGeneralTab> createState() => _TabletopGeneralTabState();
}

class _TabletopGeneralTabState extends State<TabletopGeneralTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* Auto download types
        Text("Some tabletop settings go here".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
      ],
    );
  }
}

class TabletopDeckTab extends StatefulWidget {
  const TabletopDeckTab({super.key});

  @override
  State<TabletopDeckTab> createState() => _TabletopDeckTabState();
}

class _TabletopDeckTabState extends State<TabletopDeckTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //* Auto download types
        Text("Some tabletop settings go here".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
      ],
    );
  }
}
