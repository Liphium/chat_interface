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
      'request.self': 'Are you trying to add yourself as a friend?',
      'request.self.text': "I know you're lonely, but you can't be your own friend. Sorry.",
      'requests.already.exists': 'Already sent',
      'requests.already.exists.text': "I know you want to be this person's friend, but you already sent them a request. So please chill a little bit.",
      'request.not.found': 'User not found',
      'request.not.found.text': "You sure this is your friend? Maybe you just met that person in your dreams?",

      // Chat
      'error.not_delete_conversation': 'Couldn\'t delete conversation. Try restarting the app if this conversation was just created.',
      'file.not_uploaded': 'File not found. Maybe it was deleted?',
      'file.too_large': 'The maximum file size is 10MB.',
      'chat.add_file': 'Attach a file',

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
      'request.self': 'Versuchst du dich selbst als Freund hinzuzufügen?',
      'request.self.text': "Ich weiß, dass du einsam bist, aber du kannst nicht dein eigener Freund sein. Sorry.",
      'requests.already.exists': 'Bereits gesendet',
      'requests.already.exists.text': "Ich weiß, dass du mit dieser Person befreundet sein willst, aber du hast bereits eine Anfrage gesendet. Also chill mal ein bisschen.",
      'request.not.found': 'Benutzer nicht gefunden',
      'request.not.found.text': "Bist du sicher, dass das dein Freund ist? Vielleicht hast du diese Person nur in deinen Träumen getroffen?",

      // Chat
      'error.not_delete_conversation': 'Konnte die Konversation nicht löschen. Versuche die App neu zu starten, wenn diese Konversation gerade erst erstellt wurde.',
      'file.not_uploaded': 'Datei nicht gefunden. Vielleicht wurde sie gelöscht?',
      'file.too_large': 'Die maximale Dateigröße beträgt 10MB.',
      'chat.add_file': 'Datei anhängen',

      // Game
      'no.start': 'Das Spiel konnte nicht gestartet werden. Wir entschuldigen uns für die Unannehmlichkeiten, bitte melde dich bei Support, wenn du auf dieses Problem stößt.',
    },
  };
}