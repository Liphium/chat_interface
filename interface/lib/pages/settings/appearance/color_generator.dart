part of 'theme_settings.dart';

class GeneratedColors {
  final Color primary;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color background1;
  final Color background2;
  final Color background3;

  const GeneratedColors(this.primary, this.primaryContainer, this.secondary, this.secondaryContainer, this.background1, this.background2, this.background3);
}

class ColorFactory {

  static const _containerJump = 0.5;

  final double primHue, secHue, sat, lum, lumJumps;
  final int themeMode, backgroundMode;
  const ColorFactory(this.primHue, this.secHue, this.sat, this.lum, this.themeMode, this.lumJumps, this.backgroundMode);

  Color getPrimary() => HSLColor.fromAHSL(1.0, primHue, sat, 0.7).toColor();
  Color getPrimaryContainer() => HSLColor.fromAHSL(1.0, primHue, sat, clampDouble(0.7 + (_containerJump * themeMode), 0.0, 1.0)).toColor();

  Color getSecondary() => HSLColor.fromAHSL(1.0, secHue, sat, 0.7).toColor();
  Color getSecondaryContainer() => HSLColor.fromAHSL(1.0, secHue, sat, clampDouble(0.7 + (_containerJump * themeMode), 0.0, 1.0)).toColor();

  Color getBackground1() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0, lum).toColor();
  Color getBackground2() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0, clampDouble(lum + (lumJumps * themeMode), 0.0, 1.0)).toColor();
  Color getBackground3() => HSLColor.fromAHSL(1.0, primHue, backgroundMode == 1 ? sat : 0, clampDouble(lum + (lumJumps * 2 * themeMode), 0.0, 1.0)).toColor();

  Color customHue(double hue) => HSLColor.fromAHSL(1.0, hue * 360.0, sat, 0.7).toColor();
  Color customHueContainer(double hue) => HSLColor.fromAHSL(1.0, hue * 360.0, sat, clampDouble(0.7 + (_containerJump * themeMode), 0.0, 1.0)).toColor();

}

ColorFactory buildColorFactoryFromSettings() {
  final SettingController controller = Get.find();
  var index = controller.settings[ThemeSettings.themePreset]!.getValue() as int;
  if(index > ThemeSettings.customThemeIndex) {
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

  if(index == ThemeSettings.customThemeIndex) {
    primHue = controller.settings[ThemeSettings.primaryHue]!.getValue() * 360.0;
    secHue = controller.settings[ThemeSettings.secondaryHue]!.getValue() * 360.0;
    sat = controller.settings[ThemeSettings.baseSaturation]!.getValue() as double;

    // Advanced color
    themeMode = ThemeSettings.themeModes[controller.settings[ThemeSettings.themeMode]!.getValue() as int];
    backgroundMode = controller.settings[ThemeSettings.backgroundMode]!.getValue() as int;
  }

  return ColorFactory(primHue, secHue, sat, themeMode == -1 ? ThemeSettings.baseLuminosityDark : ThemeSettings.baseLuminosityLight, themeMode, ThemeSettings.luminosityJumps, backgroundMode);
}

ThemeData getThemeData() {
  final factory = buildColorFactoryFromSettings();

  return defaultDarkTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(

      // Background color
      brightness: Brightness.dark,
      background: factory.getBackground1(),
      onBackground: factory.getBackground2(),
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
      onSecondary: Color(0xFFE5E5E5),

      // Unimportant font colors
      surface: Color(0xFFbababa),

      // Important font color
      onSurface: Color(0xFFFFFFFF),
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
    )
  );
}