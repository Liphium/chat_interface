import 'dart:async';

import 'package:chat_interface/pages/settings/appearance/color_preview.dart';
import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/default_theme.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

part 'color_generator.dart';

class ThemePreset extends SelectableItem {
  final double primaryHue;
  final double secondaryHue;
  final double baseSaturation;
  final int themeMode;
  final int backgroundMode;

  const ThemePreset(
    super.label,
    super.icon,
    this.primaryHue,
    this.secondaryHue,
    this.baseSaturation,
    this.themeMode,
    this.backgroundMode,
  );
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
  static const double luminosityJumps = 0.03;

  static final themeModes = [
    -1, // Dark
    1, // Light
  ];

  static final backgroundModes = [
    SelectableItem("custom.none".tr, Icons.close),
    SelectableItem("custom.colored".tr, Icons.color_lens),
  ];

  static final themePresets = [
    ThemePreset("theme.default_dark".tr, Icons.dark_mode, 0.54, 0.62, 0.6, 0, 0),
    ThemePreset("theme.default_light".tr, Icons.light_mode, 0.48, 0.57, 0.6, 1, 0),
    ThemePreset("theme.winter".tr, Icons.ac_unit, 0.48, 0.57, 0.82, 0, 0),
    ThemePreset("theme.custom".tr, Icons.brush, 0, 0, 0, 1, 0),
  ];
  static const int customThemeIndex = 3;

  static void addSettings() {
    SettingController.addSetting((Setting<int>(themePreset, 0)));
    SettingController.addSetting(Setting<double>(primaryHue, 0.54));
    SettingController.addSetting(Setting<double>(secondaryHue, 0.62));
    SettingController.addSetting(Setting<double>(baseSaturation, 0.6));
    SettingController.addSetting(Setting<int>(backgroundMode, 0));
    SettingController.addSetting(Setting<int>(themeMode, 0));
  }
}

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final _factory = Signal<ColorFactory?>(null);
  Timer? _timer;

  @override
  void dispose() {
    _factory.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _factory.value = buildColorFactoryFromSettings();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _factory.value = buildColorFactoryFromSettings();
    });

    if (isMobileMode()) {
      return SettingsPageBase(label: "colors", child: ColorPreview(factory: _factory, mobile: true));
    }

    return SettingsPageBase(
      label: "colors",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: ThemeSettingsElement()),

          //* Color preview
          Expanded(child: ColorPreview(factory: _factory)),
        ],
      ),
    );
  }
}

class ThemeSettingsElement extends StatefulWidget {
  const ThemeSettingsElement({super.key});

  @override
  State<ThemeSettingsElement> createState() => _ThemeSettingsElementState();
}

class _ThemeSettingsElementState extends State<ThemeSettingsElement> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("theme.presets".tr, style: Get.theme.textTheme.labelLarge),
        verticalSpacing(elementSpacing),
        ListSelectionSetting(
          setting: SettingController.settings[ThemeSettings.themePreset]! as Setting<int>,
          items: ThemeSettings.themePresets,
        ),
        verticalSpacing(sectionSpacing),
        Watch(
          (ctx) => Visibility(
            visible:
                SettingController.settings[ThemeSettings.themePreset]!.getValue() == ThemeSettings.customThemeIndex,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("theme.custom.title".tr, style: Get.theme.textTheme.labelLarge),
                verticalSpacing(defaultSpacing),

                // Sliders
                const DoubleSelectionSetting(
                  settingName: ThemeSettings.primaryHue,
                  description: "custom.primary_hue",
                  min: 0.0,
                  max: 1.0,
                ),
                verticalSpacing(defaultSpacing),

                const DoubleSelectionSetting(
                  settingName: ThemeSettings.secondaryHue,
                  description: "custom.secondary_hue",
                  min: 0.0,
                  max: 1.0,
                ),
                verticalSpacing(defaultSpacing),

                const DoubleSelectionSetting(
                  settingName: ThemeSettings.baseSaturation,
                  description: "custom.base_saturation",
                  min: 0.0,
                  max: 1.0,
                ),
                verticalSpacing(defaultSpacing),

                // Selections
                Text("custom.theme_mode".tr),
                verticalSpacing(elementSpacing),
                ListSelectionSetting(
                  setting: SettingController.settings[ThemeSettings.themeMode]! as Setting<int>,
                  items: [
                    SelectableItem("custom.dark".tr, Icons.dark_mode),
                    SelectableItem("custom.light".tr, Icons.light_mode),
                  ],
                ),
                verticalSpacing(defaultSpacing),

                Text("custom.background_mode".tr),
                verticalSpacing(elementSpacing),
                ListSelectionSetting(
                  setting: SettingController.settings[ThemeSettings.backgroundMode]! as Setting<int>,
                  items: ThemeSettings.backgroundModes,
                ),

                verticalSpacing(sectionSpacing),
              ],
            ),
          ),
        ),
        FJElevatedButton(
          onTap: () {
            final ThemeData theme = getThemeData();
            ThemeManager.changeTheme(theme);
          },
          child: Text("theme.apply".tr, style: Get.theme.textTheme.labelLarge),
        ),
      ],
    );
  }
}
