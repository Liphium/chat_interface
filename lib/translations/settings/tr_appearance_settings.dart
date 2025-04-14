import 'package:get/get.dart';

class AppearanceSettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    //* English US
    'en_US': {
      // Theme settings
      'theme.presets': 'Presets',
      'theme.default_dark': 'Default dark',
      'theme.default_light': 'Default light',
      'theme.winter': 'Winter',
      'theme.custom': 'Create your own',
      'theme.custom.title': 'Custom theme',
      'theme.primary': 'Primary color',
      'theme.secondary': 'Secondary color',
      'custom.primary_hue': 'Primary hue',
      'custom.secondary_hue': 'Secondary hue',
      'custom.base_saturation': 'Base saturation',
      'custom.theme_mode': 'Theme brightness',
      'custom.dark': 'Dark',
      'custom.light': 'Light',
      'custom.background_mode': 'What color should the background have?',
      'custom.none': 'None',
      'custom.colored': 'Primary color',
      'theme.apply': 'Apply your theme',

      // Chat theme settings
      'appearance.chat.dot_amount.title': 'Choose how many dots appear',
      'appearance.chat.dot_amount': 'Amount of dots',
      'appearance.chat.theme': 'Chat theme',
      'appearance.chat.theme.material': 'Material',
      'appearance.chat.theme.bubbles': 'Chat bubbles',
    },
  };
}
