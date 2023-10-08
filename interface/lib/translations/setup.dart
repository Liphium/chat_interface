import 'package:get/get.dart';

class SetupTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      // Error page
      'retry.text.1': 'Trying again in',
      'retry.text.2': 'seconds.',

      // Instance setup
      'setup.choose.instance': 'Choose an instance.',
      'setup.instance.name': 'Enter a new name'
    }
  };
}