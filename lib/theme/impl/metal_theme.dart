
import 'package:chat_interface/theme/default_theme.dart';
import 'package:flutter/material.dart';

final ThemeData lightMetalTheme = defaultLightTheme.copyWith(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE5E5E5),
    onPrimary: Color(0xFFE5E5E5),
    secondary: Color(0xFFE5E5E5),
    onSecondary: Color(0xFFE5E5E5),
    background: Color(0xFFE5E5E5),
    onBackground: Color(0xFFE5E5E5),
    error: Color(0xFFE5E5E5),
    onError: Color(0xFFE5E5E5),
    surface: Color(0xFFE5E5E5),
    onSurface: Color(0xFFE5E5E5),
  )
);

final ThemeData darkMetalTheme = defaultDarkTheme.copyWith(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(

    // Background color
    brightness: Brightness.dark, 
    background: Color(0xFF262627),
    onBackground: Color(0xFF1c1c1c),

    // Secondary color
    secondary: Color(0xFF99c1f1),
    secondaryContainer: Color(0xFF0d3b54),

    // Primary color
    primary: Color(0xFF99c1f1),
    primaryContainer: Color(0xFF0d3b54),

    // Tertiary color 
    tertiary: Color(0xFFf7c5db),
    onTertiary: Color(0xFFd8749f),
    tertiaryContainer: Color(0xFFd8749f),

    // Error color
    error: Color(0xFFda827c),
    onError: Color(0xFFcc6d66),
    errorContainer: Color(0xFFb5514a),

    onPrimary: Color(0xFFE5E5E5),
    onSecondary: Color(0xFFE5E5E5),
    surface: Color(0xFFE5E5E5),
    onSurface: Color(0xFFE5E5E5),
  ),
  textTheme: defaultDarkTheme.textTheme.copyWith(
    headlineMedium: defaultDarkTheme.textTheme.headlineMedium!.copyWith(
      fontFamily: 'Alfa Slab One'
    ),
  )
);