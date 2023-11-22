import 'package:get/get.dart';

class ErrorTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    
    //* English US
    'en_US': {
      'error': 'Error',
      'server.error': 'Something went wrong on the server, please try again later.',
      'node.error': 'The chat server didn\'t respond, please try again later.',
      'not.setup': 'The chat server is not set up yet, maybe try updating to the newest version?',
      'new.version': 'A new version is available, please update the app.',

      // Friends
      'requests.already.exists': 'Already sent',
      'requests.already.exists.text': "I know you want to be this person's friend, but you already sent them a request. So please chill a little bit.",

      // Game
      'no.start': 'The game couldn\'t be started. We\'re sorry for the inconvenience, please message support about this issue if you encounter it.',
    },

    //* German
    'de_DE': {
      'error': 'Fehler',
      'server.error': 'Auf dem Server ist ein Fehler aufgetreten, bitte versuche es später erneut.',
      'node.error': 'Der Chat-Server hat nicht geantwortet, bitte versuche es später erneut.',
      'not.setup': 'Der Chat-Server ist noch nicht eingerichtet, vielleicht versuchst du es mit dem Update auf die neueste Version?',
      'new.version': 'Eine neue Version ist verfügbar, bitte aktualisiere die App.',

      // Friends
      'requests.already.exists': 'Bereits gesendet',
      'requests.already.exists.text': "Ich weiß, dass du mit dieser Person befreundet sein willst, aber du hast bereits eine Anfrage gesendet. Also chill mal ein bisschen.",
    
      // Game
      'no.start': 'Das Spiel konnte nicht gestartet werden. Wir entschuldigen uns für die Unannehmlichkeiten, bitte melde dich bei Support, wenn du auf dieses Problem stößt.',
    },
  };
}