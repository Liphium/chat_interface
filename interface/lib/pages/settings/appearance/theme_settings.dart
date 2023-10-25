import 'dart:async';

import 'package:chat_interface/pages/settings/components/double_selection.dart';
import 'package:chat_interface/pages/settings/components/list_selection.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/default_theme.dart';
import 'package:chat_interface/theme/theme_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'color_generator.dart';

class ThemeSettings {

  // Advanced color
  static const String primaryHue = 'theme.primary';
  static const String secondaryHue = 'theme.secondary';
  static const String baseSaturation = 'theme.baseSaturation';

  // Background
  static const String backgroundMode = 'theme.backgroundMode'; // Colored or dark
  static const String baseLuminosity = 'theme.baseLuminosity';
  static const String themeMode = 'theme.themeMode'; // Dark or light
  static const String luminosityJumps = 'theme.luminosityJumps';

  static final themeModes = [
    -1, // Dark
    1 // Light
  ];

  static final backgroundModes = [
    SelectableItem("none".tr, Icons.close),
    SelectableItem("colored".tr, Icons.color_lens)
  ];

  static void addThemeSettings(SettingController controller) {
    controller.addSetting(Setting<double>(primaryHue, 0.45));
    controller.addSetting(Setting<double>(secondaryHue, 0.56));
    controller.addSetting(Setting<double>(baseSaturation, 0.5));

    controller.addSetting(Setting<double>(baseLuminosity, 0.5));
    controller.addSetting(Setting<int>(backgroundMode, 0));
    controller.addSetting(Setting<int>(themeMode, 0));
    controller.addSetting(Setting<double>(luminosityJumps, 0.1));
  }

}

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {

  final _colors = Rx<GeneratedColors?>(null);
  Timer? _timer;

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _colors.value = generateColorTheme();
    });
    _colors.value = generateColorTheme();

    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Column(
            children: [
        
              //* Sliders
              const DoubleSelectionSetting(settingName: ThemeSettings.primaryHue, description: "primary hue", min: 0.0, max: 1.0),
              const DoubleSelectionSetting(settingName: ThemeSettings.secondaryHue, description: "secondary hue", min: 0.0, max: 1.0),
              const DoubleSelectionSetting(settingName: ThemeSettings.baseSaturation, description: "base saturation", min: 0.0, max: 1.0),
        
              const Text("theme mode"),
              const ListSelectionSetting(settingName: ThemeSettings.themeMode, items: [SelectableItem("Dark", Icons.dark_mode), SelectableItem("Light", Icons.light_mode)]),
              
              ListSelectionSetting(settingName: ThemeSettings.backgroundMode, items: ThemeSettings.backgroundModes),
              const DoubleSelectionSetting(settingName: ThemeSettings.baseLuminosity, description: "start luminosity", min: 0.0, max: 1.0),
              const DoubleSelectionSetting(settingName: ThemeSettings.luminosityJumps, description: "lum jumps", min: 0.0, max: 0.2),

              FJElevatedButton(onTap: () {

                final ThemeData theme = getThemeData();
                Get.find<ThemeManager>().changeTheme(theme);

              }, child: const Text("Apply"))
            ],
          ),
        ),

        //* Color preview
        Obx(() {
          final colors = _colors.value!;

          return Column(
            children: [

              //* Primary
              Row(
                children: [
                  Container(color: colors.primary, width: 100, height: 100),
                  Container(color: colors.primaryContainer, width: 100, height: 100),
                ],
              ),

              //* Secondary
              Row(
                children: [
                  Container(color: colors.secondary, width: 100, height: 100),
                  Container(color: colors.secondaryContainer, width: 100, height: 100),
                ],
              ),

              Container(color: colors.background1, width: 100, height: 100),
              Container(color: colors.background2, width: 100, height: 100),
              Container(color: colors.background3, width: 100, height: 100),
            ],
          );
        }),
      ],
    );  
  }
}