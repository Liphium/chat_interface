import 'package:chat_interface/pages/settings/appearance/call_preview.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void addCallAppearanceSettings(SettingController controller) {
  // If participants should be shown in a maximized screenshare
  // 0 - Scroll view, 1 - Talking overlay, 2 - None
  controller.addSetting(Setting<int>("call_app.expansionMode", 0));

  // Postion of the participants in a maximized screenshare
  // 0 - Top, 1 - Right, 2 - Bottom, 3 - Left
  controller.addSetting(Setting<int>("call_app.expansionPosition", 1));
}

class CallSettingsPage extends StatefulWidget {
  const CallSettingsPage({super.key});

  @override
  State<CallSettingsPage> createState() => _CallSettingsPageState();
}

class _CallSettingsPageState extends State<CallSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* Preview
            Text("call_app.preview".tr, style: Get.theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing * 0.5),

            const CallPreview(),
            verticalSpacing(defaultSpacing),

            //* Expansion mode
            Text("expansion.mode".tr, style: Get.theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing * 0.5),

            ListSelectionSetting(settingName: "call_app.expansionMode", items: <SelectableItem>[
              SelectableItem("expansion.scroll_view".tr, Icons.view_list),
              SelectableItem("expansion.talking_overlay".tr, Icons.people),
              SelectableItem("expansion.none".tr, Icons.close),
            ]),

            //* Expansion positions
            Text("expansion.position".tr, style: Get.theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing * 0.5),

            ListSelectionSetting(settingName: "call_app.expansionPosition", items: <SelectableItem>[
              SelectableItem("expansion.top".tr, Icons.arrow_upward),
              SelectableItem("expansion.right".tr, Icons.arrow_forward),
              SelectableItem("expansion.bottom".tr, Icons.arrow_downward),
              SelectableItem("expansion.left".tr, Icons.arrow_back),
            ]),
          ],
        ),
      ),
    );
  }
}
