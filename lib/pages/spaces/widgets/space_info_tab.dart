import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/pages/spaces/widgets/space_studio_grid_tab.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SpaceInfoTab extends StatefulWidget {
  const SpaceInfoTab({super.key});

  @override
  State<SpaceInfoTab> createState() => _SpaceInfoTabState();
}

class _SpaceInfoTabState extends State<SpaceInfoTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      // Render the member list when connected to Studio
      if (StudioController.connected.value) {
        return SpaceStudioGridTab();
      }

      // Return a basic description of Spaces instead
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700 + sectionSpacing * 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: sectionSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpacing(75),
                Text("spaces.welcome".tr, style: Get.textTheme.headlineMedium),
                verticalSpacing(sectionSpacing),
                Text("spaces.welcome.desc".tr, style: Get.textTheme.bodyMedium),

                // Render the status of the studio connection
                Watch((ctx) {
                  if (StudioController.connectionError.value != "") {
                    return Padding(
                      padding: const EdgeInsets.only(top: sectionSpacing),
                      child: Text(StudioController.connectionError.value, style: theme.textTheme.labelMedium),
                    );
                  }

                  // Render a loading indicator
                  return Visibility(
                    visible: StudioController.connecting.value,
                    child: Padding(
                      padding: EdgeInsets.only(top: sectionSpacing),
                      child: Row(
                        children: [
                          SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: theme.colorScheme.onPrimary)),
                          horizontalSpacing(defaultSpacing),
                          Text("spaces.studio.connecting".tr, style: Get.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}
