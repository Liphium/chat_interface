part of 'theme_settings.dart';

class ColorFactory {
  static const _iconWhite = 0.5;
  static const _iconBlack = 0.7;
  static const _containerWhite = 0.85;
  static const _containerBlack = 0.17;

  final double primHue, secHue, sat, lum, lumJumps;
  final int themeMode, backgroundMode;
  const ColorFactory(this.primHue, this.secHue, this.sat, this.lum, this.themeMode, this.lumJumps, this.backgroundMode);

  Color getPrimary() => HSLColor.fromAHSL(1.0, primHue, sat, themeMode == -1 ? _iconBlack : _iconWhite).toColor();
  Color getPrimaryContainer() => HSLColor.fromAHSL(1.0, primHue, sat, themeMode == -1 ? _containerBlack : _containerWhite).toColor();

  Color getSecondary() => HSLColor.fromAHSL(1.0, secHue, sat, themeMode == -1 ? _iconBlack : _iconWhite).toColor();
  Color getSecondaryContainer() => HSLColor.fromAHSL(1.0, secHue, sat, themeMode == -1 ? _containerBlack : _containerWhite).toColor();

  Color getBackground1() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0.03, lum).toColor();
  Color getBackground2() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0.03, clampDouble(lum - 0.03, 0.0, 1.0)).toColor();
  Color getBackground3() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0.03, clampDouble(lum - 0.06, 0.0, 1.0)).toColor();

  Color completeBackground() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0, 0.0).toColor();

  Color customHue(double hue) => HSLColor.fromAHSL(1.0, hue * 360.0, sat, themeMode == -1 ? _iconBlack : _iconWhite).toColor();
  Color customHueContainer(double hue) => HSLColor.fromAHSL(1.0, hue * 360.0, sat, themeMode == -1 ? _containerBlack : _containerWhite).toColor();

  Color getFontColor() {
    final hsl = HSLColor.fromColor(getBackground1());
    return hsl.lightness > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  Color getFontColorInverse() {
    final hsl = HSLColor.fromColor(getBackground1());
    sendLog("${hsl.lightness} IMPORTANT");
    return hsl.lightness > 0.5 ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  Color getUnimportantFontColor() {
    final hsl = HSLColor.fromColor(getBackground1());
    return hsl.lightness > 0.5 ? const Color(0xFF454545) : const Color(0xFFbababa);
  }
}

ColorFactory buildColorFactoryFromSettings() {
  final SettingController controller = Get.find();
  var index = controller.settings[ThemeSettings.themePreset]!.getValue() as int;
  if (index > ThemeSettings.customThemeIndex) {
    index = ThemeSettings.customThemeIndex;
  }
  final preset = ThemeSettings.themePresets[index];

  // Base values
  var primHue = preset.primaryHue * 360.0;
  var secHue = preset.secondaryHue * 360.0;
  var sat = preset.baseSaturation;

  // Advanced color
  var themeMode = ThemeSettings.themeModes[preset.themeMode];
  var backgroundMode = preset.backgroundMode;

  if (index == ThemeSettings.customThemeIndex) {
    primHue = controller.settings[ThemeSettings.primaryHue]!.getValue() * 360.0;
    secHue = controller.settings[ThemeSettings.secondaryHue]!.getValue() * 360.0;
    sat = controller.settings[ThemeSettings.baseSaturation]!.getValue() as double;

    // Advanced color
    themeMode = ThemeSettings.themeModes[controller.settings[ThemeSettings.themeMode]!.getValue() as int];
    backgroundMode = controller.settings[ThemeSettings.backgroundMode]!.getValue() as int;
  }

  return ColorFactory(primHue, secHue, sat, themeMode == -1 ? ThemeSettings.baseLuminosityDark : ThemeSettings.baseLuminosityLight, themeMode,
      ThemeSettings.luminosityJumps, backgroundMode);
}

ThemeData getThemeData() {
  final factory = buildColorFactoryFromSettings();

  if (factory.themeMode.isNegative) {
    //* Dark theme
    return defaultDarkTheme.copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme(
          // Background color
          brightness: Brightness.dark,
          inverseSurface: factory.getBackground1(),
          onInverseSurface: factory.getBackground2(),
          primaryContainer: factory.getBackground3(),

          // Online color
          secondary: factory.customHue(0.3),

          // AFK color
          secondaryContainer: factory.customHue(0.14),

          // Primary color
          primary: factory.getPrimaryContainer(),
          onPrimary: factory.getPrimary(),

          // Tertiary color
          tertiary: factory.getSecondary(),
          onTertiary: factory.getSecondaryContainer(),
          tertiaryContainer: factory.getSecondaryContainer(),

          // Error color
          error: factory.customHue(0.0),
          onError: factory.customHueContainer(0.0),
          errorContainer: factory.customHueContainer(0.0),

          // Unused
          onSecondary: const Color(0xFFbababa),

          // Unimportant font colors
          surface: factory.getUnimportantFontColor(),

          // Important font color
          onSurface: factory.getFontColor(),
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
            color: factory.getUnimportantFontColor(),
          ),
          bodyMedium: defaultDarkTheme.textTheme.bodyMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: factory.getUnimportantFontColor(),
          ),
          bodyLarge: defaultDarkTheme.textTheme.bodyLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: factory.getUnimportantFontColor(),
          ),

          //* Labels
          labelLarge: defaultDarkTheme.textTheme.labelLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),
          labelMedium: defaultDarkTheme.textTheme.labelMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),
          labelSmall: defaultDarkTheme.textTheme.labelSmall!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),

          //* Titles
          titleLarge: defaultDarkTheme.textTheme.titleLarge!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: factory.getFontColor(),
          ),
          titleMedium: defaultDarkTheme.textTheme.titleMedium!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: factory.getFontColor(),
          ),
          titleSmall: defaultDarkTheme.textTheme.titleSmall!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: factory.getFontColor(),
          ),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: factory.completeBackground(),
            borderRadius: BorderRadius.circular(defaultSpacing),
          ),
          textStyle: defaultDarkTheme.textTheme.labelMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),
        ));
  } else {
    //* Light theme
    return defaultLightTheme.copyWith(
        brightness: Brightness.light,
        colorScheme: ColorScheme(
          // Background color
          brightness: Brightness.light,
          inverseSurface: factory.getBackground1(),
          onInverseSurface: factory.getBackground2(),
          primaryContainer: factory.getBackground3(),

          // Online color
          secondary: factory.customHue(0.3),

          // AFK color
          secondaryContainer: factory.customHue(0.14),

          // Primary color
          primary: factory.getPrimaryContainer(),
          onPrimary: factory.getPrimary(),

          // Tertiary color
          tertiary: factory.getSecondary(),
          onTertiary: factory.getSecondaryContainer(),
          tertiaryContainer: factory.getSecondaryContainer(),

          // Error color
          error: factory.customHue(0.0),
          onError: factory.customHueContainer(0.0),
          errorContainer: factory.customHueContainer(0.0),

          // Unused
          onSecondary: factory.getFontColor(),

          // Unimportant font colors
          surface: factory.getUnimportantFontColor(),

          // Important font color
          onSurface: factory.getFontColor(),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF99c1f1),
          selectionColor: Color(0xFF5c5c5c),
          selectionHandleColor: Color(0xFF99c1f1),
        ),
        dividerColor: const Color(0xFF5c5c5c),
        textTheme: defaultLightTheme.textTheme.copyWith(
          //* Headlines
          headlineMedium: defaultLightTheme.textTheme.headlineMedium!.copyWith(
            fontFamily: 'Roboto Mono',
            fontWeight: FontWeight.bold,
          ),

          //* Normal body text
          bodySmall: defaultLightTheme.textTheme.bodySmall!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: factory.getUnimportantFontColor(),
          ),
          bodyMedium: defaultLightTheme.textTheme.bodyMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: factory.getUnimportantFontColor(),
          ),
          bodyLarge: defaultLightTheme.textTheme.bodyLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: factory.getUnimportantFontColor(),
          ),

          //* Labels
          labelLarge: defaultLightTheme.textTheme.labelLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),
          labelMedium: defaultLightTheme.textTheme.labelMedium!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),
          labelSmall: defaultLightTheme.textTheme.labelSmall!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: factory.getFontColor(),
          ),

          //* Titles
          titleLarge: defaultLightTheme.textTheme.titleLarge!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: factory.getFontColor(),
          ),
          titleMedium: defaultLightTheme.textTheme.titleMedium!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: factory.getFontColor(),
          ),
          titleSmall: defaultLightTheme.textTheme.titleSmall!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: factory.getFontColor(),
          ),
        ));
  }
}
