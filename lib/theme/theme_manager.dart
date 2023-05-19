import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'impl/metal_theme.dart';

class ThemeManager extends GetxController {

  final themes = [
    CustomTheme('Metal', lightMetalTheme, darkMetalTheme),
  ];

  final currentTheme = 0.obs;
  final brightness = Brightness.dark.obs;

  // Changes the color theme
  void changeTheme(int index) {
    currentTheme.value = index;
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