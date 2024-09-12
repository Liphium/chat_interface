import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeManager extends GetxController {
  final currentTheme = getThemeDataFromFactory(buildColorFactoryFromPreset(ThemeSettings.themePresets[0])).obs;

  final brightness = Brightness.dark.obs;

  // Changes the color theme
  void changeTheme(ThemeData theme) {
    currentTheme.value = theme;
  }

  // Changes the brightness (light or dark)
  void changeBrightness(Brightness value) {
    brightness.value = value;
  }
}

class CustomTheme {
  // Theme properties
  final String name;
  final ThemeData light;
  final ThemeData dark;

  const CustomTheme(this.name, this.light, this.dark);

  ThemeData getData(Brightness brightness) => brightness == Brightness.light ? light : dark;
}
