import 'package:get/get.dart';

class ErrorTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    
    //* English US
    'en_US': {
      'error': 'Error',
      'server.error': 'Something went wrong on the server, please try again later.',
      'new.version': 'A new version is available, please update the app.',

      // Friends
      'requests.already.exists': 'Already sent',
      'requests.already.exists.text': "I know you want to be this person's friend, but you already sent them a request. So please chill a little bit.",
    },

    //* German
    'de_DE': {
      'error': 'Fehler',
      'server.error': 'Auf dem Server ist ein Fehler aufgetreten, bitte versuche es später erneut.',
      'new.version': 'Eine neue Version ist verfügbar, bitte aktualisiere die App.',

      // Friends
      'requests.already.exists': 'Bereits gesendet',
      'requests.already.exists.text': "Ich weiß, dass du mit dieser Person befreundet sein willst, aber du hast bereits eine Anfrage gesendet. Also chill mal ein bisschen.",
    },
  };
}