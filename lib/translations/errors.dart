import 'package:get/get.dart';

class ErrorTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          'error': 'Error',
          'server.not_found': 'The server couldn\'t be reached. Make sure you have the right domain.',
          'server.error': 'Something went wrong on the server, please try again later.',
          'server.error.code': 'Something went wrong on the server, please try again later. Status code: @code',
          'friends.error': 'There was an error while loading your friends. Please try again later or contact your administrator.',
          'node.error': 'The chat server didn\'t respond, please try again later.',
          'mail.error': 'There was an error with our mail servers. Please try again later or contact your administrator.',
          'app.error': 'There was an error with the app. Please report this to the developers.',
          'not.setup': 'The chat server is not set up yet, maybe try updating to the newest version?',
          'new.version': 'A new version is available, please update the app.',
          'key.error': 'Something went wrong with your keys. Maybe try restarting the app or contacting support?',
          'already.deleted': 'This object was already deleted.',
          'no.permission': 'You don\'t have permission to do that.',
          'spaces.connection_error': 'Something went wrong with the spaces connection. Please try again later.',
          'invalid.method': 'This is incorrect. Please try again.',
          'sessions.limit': 'You are already registered with 5 devices. Please log out of one of them to log in here.',
          'password.incorrect': 'Your password is incorrect. Please try again.',

          // Friends
          'request.self': 'Are you trying to add yourself as a friend?',
          'request.self.text': "I know you're lonely, but you can't be your own friend. Sorry.",
          'requests.already.exists': 'Already sent',
          'requests.already.exists.text': "I know you want to be this person's friend, but you already sent them a request. So please chill a little bit.",
          'request.not.found': 'User not found',
          'request.not.found.text': "You sure this is your friend? Maybe you just met them in your dreams?",

          // Chat
          'error.not_delete_conversation': 'Couldn\'t delete conversation. Try restarting the app if this conversation was just created.',
          'file.not_uploaded': 'File not found.',
          'file.too_large': 'The maximum file size is @1MB.',
          'file.unsafe': 'The provider of this file (@domain) isn\'t trusted.',
          'chat.add_file': 'Attach a file',
          'message.delete_error': 'Couldn\'t delete message. Please try again later.',

          // Settings
          'profile_picture.not_uploaded': 'Your profile picture couldn\'t be uploaded. Please try again later or contact support.',
          'profile_picture.not_set': 'Your profile picture couldn\'t be set. Please try again later or contact support.',
          'username.invalid': 'Your username doesn\'t match the requirements. Please make it longer than 3 characters.',
          'display_name.invalid': 'Your display name doesn\'t match the requirements. Please make it longer than 3 characters.',
          'username.taken': 'This username is taken, please choose a different one.',
          'password.mismatch': 'The passwords don\'t match.',

          // Game
          'tabletop.invalid_action': 'You can\'t do that right now. Please try again later.',
          'no.start': 'The game couldn\'t be started. We\'re sorry for the inconvenience, please message support about this issue if you encounter it.',
        },

        //* German
        'de_DE': {
          /*
          'error': 'Fehler',
          'server.error': 'Auf dem Server ist ein Fehler aufgetreten, bitte versuche es später erneut.',
          'node.error': 'Der Chat-Server hat nicht geantwortet, bitte versuche es später erneut.',
          'not.setup': 'Der Chat-Server ist noch nicht eingerichtet, vielleicht versuchst du es mit dem Update auf die neueste Version?',
          'new.version': 'Eine neue Version ist verfügbar, bitte aktualisiere die App.',
          'key.error': 'Es ist ein Fehler mit deinen Schlüsseln aufgetreten. Vielleicht versuchst du es mit dem Neustart der App oder kontaktierst den Support?',
          'already.deleted': 'Dieses Objekt wurde bereits gelöscht.',
          'no.permission': 'Du hast keine Berechtigung, das zu tun.',
          'spaces.connection_error': 'Bei der Verbindung zu den Spaces ist ein Fehler aufgetreten. Bitte versuche es später erneut.',

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
          'message.delete_error': 'Die Nachricht konnte nicht gelöscht werden. Bitte versuche es später erneut.',

          // Settings
          'profile_picture.not_uploaded': 'Dein Profilbild konnte nicht hochgeladen werden. Bitte versuche es später erneut oder kontaktiere den Support.',
          'profile_picture.not_set': 'Dein Profilbild konnte nicht gesetzt werden. Bitte versuche es später erneut oder kontaktiere den Support.',
          'username.invalid': 'Dein Benutzername entspricht nicht den Anforderungen. Bitte mache ihn länger als 3 Zeichen und verwende nur Buchstaben und Zahlen.',
          'username.taken': 'Dieser Benutzername ist bereits vergeben, bitte wähle einen anderen.',
          'password.mismatch': 'Die Passwörter stimmen nicht überein.',

          // Game
          'no.start': 'Das Spiel konnte nicht gestartet werden. Wir entschuldigen uns für die Unannehmlichkeiten, bitte melde dich bei Support, wenn du auf dieses Problem stößt.',
          */
        },
      };
}
