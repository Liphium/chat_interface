import 'dart:async';

import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/default_theme.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'color_generator.dart';

class ThemePreset extends SelectableItem {
  final double primaryHue;
  final double secondaryHue;
  final double baseSaturation;
  final int themeMode;
  final int backgroundMode;

  const ThemePreset(super.label, super.icon, this.primaryHue, this.secondaryHue, this.baseSaturation, this.themeMode, this.backgroundMode);
}

class ThemeSettings {
  // Presets
  static const String themePreset = 'theme.preset'; // Dark or light

  // Advanced color
  static const String themeMode = 'theme.themeMode'; // Dark or light
  static const String primaryHue = 'theme.primary';
  static const String secondaryHue = 'theme.secondary';
  static const String baseSaturation = 'theme.baseSaturation';
  static const String backgroundMode = 'theme.backgroundMode'; // Colored or dark

  static const double baseLuminosityLight = 0.87;
  static const double baseLuminosityDark = 0.13;
  static const double luminosityJumps = 0.04;

  static final themeModes = [
    -1, // Dark
    1 // Light
  ];

  static final backgroundModes = [SelectableItem("custom.none".tr, Icons.close), SelectableItem("custom.colored".tr, Icons.color_lens)];

  static final themePresets = [
    ThemePreset("theme.default_dark".tr, Icons.dark_mode, 0.54, 0.62, 0.6, 0, 0),
    ThemePreset("theme.default_light".tr, Icons.light_mode, 0.48, 0.57, 0.6, 1, 0),
    ThemePreset("theme.winter".tr, Icons.ac_unit, 0.48, 0.57, 0.82, 0, 0),
    ThemePreset("theme.custom".tr, Icons.brush, 0, 0, 0, 1, 0),
  ];
  static const int customThemeIndex = 3;

  static void addThemeSettings(SettingController controller) {
    controller.addSetting(Setting<int>(themePreset, 0));
    controller.addSetting(Setting<double>(primaryHue, 0.54));
    controller.addSetting(Setting<double>(secondaryHue, 0.62));
    controller.addSetting(Setting<double>(baseSaturation, 0.6));
    controller.addSetting(Setting<int>(backgroundMode, 0));
    controller.addSetting(Setting<int>(themeMode, 0));
  }
}

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final _factory = Rx<ColorFactory?>(null);
  Timer? _timer;

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingController>();

    _factory.value = buildColorFactoryFromSettings();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _factory.value = buildColorFactoryFromSettings();
    });

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("theme.presets".tr, style: Get.theme.textTheme.labelLarge),
              verticalSpacing(defaultSpacing),
              ListSelectionSetting(settingName: ThemeSettings.themePreset, items: ThemeSettings.themePresets),
              verticalSpacing(sectionSpacing),
              Obx(() => Visibility(
                  visible: controller.settings[ThemeSettings.themePreset]!.getValue() == ThemeSettings.customThemeIndex,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("theme.custom.title".tr, style: Get.theme.textTheme.labelLarge),
                      verticalSpacing(defaultSpacing),

                      //* Sliders
                      const DoubleSelectionSetting(settingName: ThemeSettings.primaryHue, description: "custom.primary_hue", min: 0.0, max: 1.0),
                      verticalSpacing(defaultSpacing),

                      const DoubleSelectionSetting(settingName: ThemeSettings.secondaryHue, description: "custom.secondary_hue", min: 0.0, max: 1.0),
                      verticalSpacing(defaultSpacing),

                      const DoubleSelectionSetting(settingName: ThemeSettings.baseSaturation, description: "custom.base_saturation", min: 0.0, max: 1.0),
                      verticalSpacing(defaultSpacing),

                      //* Selections
                      Text(
                        "custom.theme_mode".tr,
                      ),
                      verticalSpacing(elementSpacing),
                      ListSelectionSetting(settingName: ThemeSettings.themeMode, items: [SelectableItem("custom.dark".tr, Icons.dark_mode), SelectableItem("custom.light".tr, Icons.light_mode)]),
                      verticalSpacing(defaultSpacing),

                      Text(
                        "custom.background_mode".tr,
                      ),
                      verticalSpacing(elementSpacing),
                      ListSelectionSetting(settingName: ThemeSettings.backgroundMode, items: ThemeSettings.backgroundModes),

                      verticalSpacing(sectionSpacing)
                    ],
                  ))),
              FJElevatedButton(
                  onTap: () {
                    final ThemeData theme = getThemeData();
                    Get.find<ThemeManager>().changeTheme(theme);
                  },
                  child: Text("theme.apply".tr, style: Get.theme.textTheme.labelLarge))
            ],
          ),
        ),

        //* Color preview
        Expanded(
          child: Obx(() {
            final colors = _factory.value!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.getBackground2(),
                  borderRadius: BorderRadius.circular(defaultSpacing),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: sectionSpacing, right: sectionSpacing, left: sectionSpacing),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          color: colors.getPrimaryContainer(),
                        ),
                        padding: const EdgeInsets.all(defaultSpacing),
                        height: 60,
                        child: Row(
                          children: [
                            Icon(Icons.color_lens, color: colors.getPrimary(), size: 40),
                            horizontalSpacing(defaultSpacing),
                            Expanded(child: Text("theme.primary".tr, style: Get.theme.textTheme.labelLarge)),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(sectionSpacing),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          color: colors.getSecondaryContainer(),
                        ),
                        padding: const EdgeInsets.all(defaultSpacing),
                        height: 60,
                        child: Row(
                          children: [
                            Icon(Icons.color_lens, color: colors.getSecondary(), size: 40),
                            horizontalSpacing(defaultSpacing),
                            Expanded(child: Text("theme.secondary".tr, style: Get.theme.textTheme.labelLarge)),
                          ],
                        ),
                      ),
                    ),
                    verticalSpacing(100),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        color: colors.getBackground3(),
                      ),
                      padding: const EdgeInsets.all(defaultSpacing),
                      height: 60,
                      child: Row(
                        children: [
                          Icon(Icons.person, color: colors.getPrimary(), size: 40),
                          horizontalSpacing(defaultSpacing),
                          Expanded(child: Text(Get.find<StatusController>().name.value, style: Get.theme.textTheme.labelLarge)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
