import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallPreview extends StatefulWidget {
  const CallPreview({super.key});

  @override
  State<CallPreview> createState() => _CallPreviewState();
}

class _CallPreviewState extends State<CallPreview> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    SettingController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing * 0.5),
      child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Column(
            children: [
              //* Top preview
              Obx(() => Visibility(
                  visible: controller.settings["call_app.expansionPosition"]!.getValue() == 0,
                  child: Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: defaultSpacing),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: _buildEntities(theme, 0, defaultSpacing)))))),

              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    //* Left preview
                    Obx(() => Visibility(
                        visible: controller.settings["call_app.expansionPosition"]!.getValue() == 3,
                        child: Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.only(right: defaultSpacing),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: _buildEntities(theme, defaultSpacing, 0)))))),

                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          color: theme.colorScheme.primaryContainer,
                        ),
                      ),
                    ),

                    //* Right preview
                    Obx(() => Visibility(
                        visible: controller.settings["call_app.expansionPosition"]!.getValue() == 1,
                        child: Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.only(left: defaultSpacing),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: _buildEntities(theme, defaultSpacing, 0)))))),
                  ],
                ),
              ),

              //* Bottom preview
              Obx(() => Visibility(
                  visible: controller.settings["call_app.expansionPosition"]!.getValue() == 2,
                  child: Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(top: defaultSpacing),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: _buildEntities(theme, 0, defaultSpacing)))))),
            ],
          )),
    );
  }

  // Build the entities for the preview
  List<Widget> _buildEntities(ThemeData theme, double bottom, double right) {
    return [
      Padding(
        padding: EdgeInsets.only(bottom: bottom, right: right),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(defaultSpacing),
                border: Border.all(color: Colors.green, width: 2),
              ),
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 25,
                child: Padding(
                    padding: const EdgeInsets.all(defaultSpacing * 0.5),
                    child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(defaultSpacing),
                        ))),
              )),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: bottom, right: right),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(defaultSpacing),
              ),
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 25,
                child: Padding(
                    padding: const EdgeInsets.all(defaultSpacing * 0.5),
                    child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(defaultSpacing),
                        ))),
              )),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(bottom: bottom, right: right),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(defaultSpacing),
              ),
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: 25,
                child: Padding(
                    padding: const EdgeInsets.all(defaultSpacing * 0.5),
                    child: Container(
                        width: 75,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(defaultSpacing),
                        ))),
              )),
        ),
      )
    ];
  }
}
