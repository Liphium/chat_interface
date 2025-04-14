import 'package:chat_interface/theme/default_theme.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

final ThemeData lightMetalTheme = defaultLightTheme.copyWith(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE5E5E5),
    onPrimary: Color(0xFFE5E5E5),
    secondary: Color(0xFFE5E5E5),
    onSecondary: Color(0xFFE5E5E5),
    inverseSurface: Color(0xFFE5E5E5),
    onInverseSurface: Color(0xFFE5E5E5),
    error: Color(0xFFE5E5E5),
    onError: Color(0xFFE5E5E5),
    surface: Color(0xFFE5E5E5),
    onSurface: Color(0xFFE5E5E5),
  ),
);

final ThemeData darkMetalTheme = defaultDarkTheme.copyWith(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    // Background color
    brightness: Brightness.dark,
    inverseSurface: Color(0xFF292929),
    onInverseSurface: Color(0xFF1c1c1c),
    primaryContainer: Color(0xFF171717),

    // Online color
    secondary: Color(0xFF7cda81),

    // AFK color
    secondaryContainer: Color(0xFFF5C211),

    // Primary color
    primary: Color(0xFF0d3b54),
    onPrimary: Color(0xFF99c1f1),

    // Tertiary color
    tertiary: Color(0xFFf7c5db),
    onTertiary: Color(0xFFd8749f),
    tertiaryContainer: Color(0xFFd8749f),

    // Error color
    error: Color(0xFFda827c),
    onError: Color(0xFFcc6d66),
    errorContainer: Color.fromARGB(255, 77, 15, 10),

    // Unused
    onSecondary: Color(0xFFE5E5E5),

    // Unimportant font colors
    surface: Color(0xFFbababa),

    // Important font color
    onSurface: Color(0xFFFFFFFF),
  ),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: const Color(0xFF171717),
      borderRadius: BorderRadius.circular(defaultSpacing),
    ),
    textStyle: defaultDarkTheme.textTheme.labelMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFFFFFFF),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Color(0xFF99c1f1),
    selectionColor: Color(0xFF5c5c5c),
    selectionHandleColor: Color(0xFF99c1f1),
  ),
  dividerColor: const Color(0xFF5c5c5c),
  textTheme: defaultDarkTheme.textTheme.copyWith(
    //* Headlines
    headlineMedium: defaultDarkTheme.textTheme.headlineMedium!.copyWith(
      fontFamily: 'Roboto Mono',
      fontWeight: FontWeight.bold,
    ),

    //* Normal body text
    bodySmall: defaultDarkTheme.textTheme.bodySmall!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFbababa),
    ),
    bodyMedium: defaultDarkTheme.textTheme.bodyMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFbababa),
    ),
    bodyLarge: defaultDarkTheme.textTheme.bodyLarge!.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFbababa),
    ),

    //* Labels
    labelLarge: defaultDarkTheme.textTheme.labelLarge!.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFFFFFFF),
    ),
    labelMedium: defaultDarkTheme.textTheme.labelMedium!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFFFFFFF),
    ),
    labelSmall: defaultDarkTheme.textTheme.labelSmall!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: const Color(0xFFFFFFFF),
    ),

    //* Titles
    titleLarge: defaultDarkTheme.textTheme.titleLarge!.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFFFFFFF),
    ),
    titleMedium: defaultDarkTheme.textTheme.titleMedium!.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: const Color(0xFFFFFFFF),
    ),
    titleSmall: defaultDarkTheme.textTheme.titleSmall!.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: const Color(0xFFFFFFFF),
    ),
  ),
);
