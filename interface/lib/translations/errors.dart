import 'package:get/get.dart';

class ErrorTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    
    //* English US
    'en_US': {
      'error': 'Error',
      'server.error': 'Something went wrong on the server, please try again later.',
      'new.version': 'A new version is available, please update the app.',
    },

    //* German
    'de_DE': {
      'error': 'Fehler',
      'server.error': 'Auf dem Server ist ein Fehler aufgetreten, bitte versuche es später erneut.',
      'new.version': 'Eine neue Version ist verfügbar, bitte aktualisiere die App.',
    },
  };
}