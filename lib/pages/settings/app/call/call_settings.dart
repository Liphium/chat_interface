import 'package:chat_interface/pages/settings/app/call/call_preview.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
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

  final _expansionModes = ["expansion.scroll_view", "expansion.talking_overlay", "expansion.none"];
  final _expansionIcons = [Icons.view_list, Icons.people, Icons.close];

  final _expansionPositions = ["expansion.top", "expansion.right", "expansion.bottom", "expansion.left"];
  final _expansionPositionsIcons = [Icons.arrow_upward, Icons.arrow_forward, Icons.arrow_downward, Icons.arrow_back];

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    SettingController controller = Get.find();

    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.5),
              child: Text("settings.categories.call_app".tr, style: Theme.of(context).textTheme.headlineMedium)
            ),
            verticalSpacing(defaultSpacing),
      
            //* Preview
            Text("call_app.preview".tr, style: theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing * 0.5),
      
            const CallPreview(),
            verticalSpacing(defaultSpacing),

            //* Expansion mode
            Text("expansion.mode".tr, style: theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing * 0.5),

            Padding(
              padding: const EdgeInsets.all(defaultSpacing * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _expansionModes.length,
                itemBuilder: (context, index) {

                  final first = index == 0;
                  final last = index == _expansionModes.length - 1;
                  
                  final radius = BorderRadius.vertical(
                    top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                    bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                    child: Obx(() => 
                      Material(
                        color: controller.settings["call_app.expansionMode"]!.getWhenValue(0, 0) == index ? theme.colorScheme.secondaryContainer :
                          theme.colorScheme.background,
                        borderRadius: radius,
                        child: InkWell(
                          borderRadius: radius,
                          onTap: () {
                            controller.settings["call_app.expansionMode"]!.setValue(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing),
                            child: Row(
                              children: [
                                Icon(_expansionIcons[index]),
                                horizontalSpacing(defaultSpacing),
                                Text(_expansionModes[index].tr, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      )
                    ),
                  );
                },
              ),
            ),

            //* Expansion positions
            Text("expansion.position".tr, style: theme.textTheme.labelLarge),
            verticalSpacing(defaultSpacing * 0.5),

            Padding(
              padding: const EdgeInsets.all(defaultSpacing * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _expansionPositions.length,
                itemBuilder: (context, index) {

                  final first = index == 0;
                  final last = index == _expansionPositions.length - 1;
                  
                  final radius = BorderRadius.vertical(
                    top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                    bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                    child: Obx(() => 
                      Material(
                        color: controller.settings["call_app.expansionPosition"]!.getWhenValue(0, 0) == index ? theme.colorScheme.secondaryContainer :
                          theme.colorScheme.background,
                        borderRadius: radius,
                        child: InkWell(
                          borderRadius: radius,
                          onTap: () {
                            controller.settings["call_app.expansionPosition"]!.setValue(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing),
                            child: Row(
                              children: [
                                Icon(_expansionPositionsIcons[index]),
                                horizontalSpacing(defaultSpacing),
                                Text(_expansionPositions[index].tr, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      )
                    ),
                  );
                },
              ),
            ),
      
          ],
        ),
      ),
    );
  }
}