import 'package:get/get.dart';

class SetupTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    //* English US
    'en_US': {
      // Error page
      'retry.text.1': 'Trying again in',
      'retry.text.2': 'seconds.',

      // Instance setup
      'setup.choose.instance': 'Choose an instance.',
      'setup.instance.name': 'Enter a new name'
    },

    //* German
    'de_DE': {
      // Error page
      'retry.text.1': 'Versuche es in',
      'retry.text.2': 'Sekunden erneut.',

      // Instance setup
      'setup.choose.instance': 'Wähle eine Instanz.',
      'setup.instance.name': 'Gib einen Namen ein'
    }
  };
}