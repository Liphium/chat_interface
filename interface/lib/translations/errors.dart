import 'package:get/get.dart';

class ErrorTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    
    //* English US
    'en_US': {
      'new.version': 'A new version is available, please update the app.',
    },

    //* German
    'de_DE': {
      'new.version': 'Eine neue Version ist verfügbar, bitte aktualisiere die App.',
    },
  };
}