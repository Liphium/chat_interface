import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

class ThemeManager {
  static final currentTheme = signal(
    getThemeDataFromFactory(buildColorFactoryFromPreset(ThemeSettings.themePresets[0])),
  );

  static final brightness = signal(Brightness.dark);

  // Changes the color theme
  static void changeTheme(ThemeData theme) {
    currentTheme.value = theme;
  }

  // Changes the brightness (light or dark)
  static void changeBrightness(Brightness value) {
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
