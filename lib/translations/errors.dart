import 'package:get/get.dart';

class ErrorTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    //* English US
    'en_US': {
      'error': 'Error',
      'error.no_connection':
          'There was an error while connecting to the server. Please make sure you are connected to the internet and have a stable connection to your town.',
      'render.error': 'Elements of type @type aren\'t supported.',
      'server.not_found': 'The server couldn\'t be reached. Make sure you have the right domain.',
      'error.network': 'Seems like you are offline. Please try to check the connection of your device.',
      'error.untrusted_server':
          'This action couldn\'t be completed because @domain isn\'t trusted. Check your settings if you want to trust this server.',
      'server.error': 'Something went wrong on the server, please try again later.',
      'other.server.error':
          'It seems like the town this conversation is hosted on is currently down. Please try again later. We\'ll automatically try restoring a connection.',
      'server.error.code': 'Something went wrong on the server, please try again later. Status code: @code',
      'friends.error':
          'There was an error while loading your friends. Please try again later or contact your administrator.',
      'node.error': 'The chat server didn\'t respond, please try again later.',
      'mail.error': 'There was an error with our mail servers. Please try again later or contact your administrator.',
      'app.error': 'There was an error with the app. Please report this to the developers.',
      'not.setup': 'The chat server is not set up yet, maybe try updating to the newest version?',
      'not.found': 'This wasn\'t found. Maybe it has already been deleted?',
      'new.version': 'A new version is available, please update the app.',
      'key.error': 'Something went wrong with your keys. Maybe try restarting the app or contacting support?',
      'keys.invalid':
          'Invalid keys found. This means that the server could\'ve been hacked or someone is trolling you.',
      'already.deleted': 'This object was already deleted.',
      'no.permission': 'You don\'t have permission to do that.',
      'spaces.connection_error': 'Something went wrong with the spaces connection. Please try again later.',
      'invalid.method': 'This is incorrect. Please try again.',
      'sessions.limit': 'You are already registered with 5 devices. Please log out of one of them to log in here.',
      'password.incorrect': 'Your password is incorrect. Please try again.',
      'protocol.error.server':
          'The town you are trying to connect to runs an outdated version of Liphium. Please contact the owners of that town to update to the latest version.',
      'protocol.error.client':
          'The town you are trying to connect to runs a more up to date version of Liphium. Please update your app to make sure everything works fine.',
      'spaces.not.setup':
          'Spaces is not supported in your town. Please contact the owners of this town and ask them to set up Spaces.',
      'not.supported': 'This feature is not supported on this platform.',
      'profile.conversation_not_found': 'You are not in a conversation with this person. Please create one first.',
      'secure_storage.not_supported': 'Secure storage is not supported on your platform.',
      'secure_storage.unlock_failed': 'Couldn\'t unlock keyring. Please make sure everything is set up correctly.',

      // Friends
      'request.friend.exists': 'Already added',
      'request.friend.exists.text':
          'If you want more friends you can\'t just add the same person, that\'s not how this works.',
      'request.self': 'Are you trying to add yourself as a friend?',
      'request.self.text': "I know you're lonely, but you can't be your own friend. Sorry.",
      'requests.already.exists': 'Already sent',
      'requests.already.exists.text':
          "I know you want to be this person's friend, but you already sent them a request. So please chill a little bit.",
      'request.not.found': 'User not found',
      'request.not.found.text': "You sure this is your friend? Maybe you just met them in your dreams?",
      'requests.error':
          'There was an error with accepting this request. Please try again later or update to the latest version.',

      // Chat
      'conversations.error': 'Conversation error',
      'conversations.amount':
          'You have reached the maximum amount of @amount conversations. Please delete old ones to create more.',
      'conversations.name.length':
          'The conversation name you specified is longer than allowed. Please use less than @length characters.',
      'conversations.name_needed': 'Please specify a name for this conversation.',
      'conversations.too_many_members': 'This conversation allows a maximum of @amount members.',
      'squares.name_needed': 'Please specify a name for this Square.',
      'squares.name.length':
          'The Square name you specified is longer than allowed. Please use less than @length characters.',
      'topic.name_needed': 'Please specify a name for this topic.',
      'topic.name.length':
          'The topic name you specified is longer than allowed. Please use less than @length characters.',
      'squares.space.name_needed': 'Please specify a name for this Space.',
      'squares.space.name.length':
          'The Space name length you specified is longer than allowed. Please use less than @length characters.',
      'squares.space.already_added': 'This Space has already been added.',
      'squares.too_many_members': 'This Square allows a maximum of @amount members.',
      'conversation.delete_error': 'You can\'t delete this conversation yet. Please try again later.',
      'error.not_delete_conversation':
          'Couldn\'t delete conversation. Try restarting the app if this conversation was just created.',
      'file.not_uploaded': 'File not found.',
      'file.too_large': 'The maximum file size is @1MB.',
      'file.too_many': 'You can\'t attach more than 5 files to a message.',
      'file.unsafe': 'The provider of this file (@domain) isn\'t trusted.',
      'file.no_save_location': 'Please select a save location for your file.',
      'chat.add_file': 'Attach a file',
      'message.delete_error': 'Couldn\'t delete message. Please try again later.',
      'group.data_too_long':
          'The data of this conversation became too long. This shouldn\'t normally happen. You should probably contact the developers of this app.',
      'zap.no_save_location': 'Please select a save location for your file to use Zap.',
      'zap.already_exists': 'This file already exists. Please choose a different place to store this file.',
      'zap.error': 'Zap Error',
      'zap.no_mobile':
          'Zap is currently not supported on mobile. We still have some things we need to figure out. Please wait until the app gets a little more stable. We\'ll announce once we have an estimated time when Zap will be available.',

      // Settings
      'profile_picture.not_uploaded':
          'Your profile picture couldn\'t be uploaded. Please try again later or contact support.',
      'profile_picture.not_set': 'Your profile picture couldn\'t be set. Please try again later or contact support.',
      'username.invalid': 'Your username doesn\'t match the requirements. Please make it longer than 3 characters.',
      'display_name.invalid':
          'Your display name doesn\'t match the requirements. Please make it longer than 3 characters.',
      'username.taken': 'This username is taken, please choose a different one.',
      'password.mismatch': 'The passwords don\'t match.',

      // Spaces, Studio and Tabletop
      'tabletop.not_found': 'The table wasn\'t found for some reason, maybe try rejoining the Space?',
      'tabletop.already_joined': 'You are already in tabletop. You can\'t join again.',
      'tabletop.couldnt_create': 'There was an issue during the table creation. Please report this to the developers.',
      'tabletop.object_not_found': 'This object doesn\'t exist anymore, maybe it has already been deleted?',
      'tabletop.object_already_held':
          'This is object is already being held by someone else. Please try to modify it again later.',
      'tabletop.object_not_in_queue':
          'You didn\'t ask to modify this object before the actual modification. This is an issue with the app, please contact the developers.',
      'tabletop.invalid_action': 'You can\'t do that right now. Please try again later.',
      'no.start':
          'The game couldn\'t be started. We\'re sorry for the inconvenience, please message support about this issue if you encounter it.',
      'error.studio.rtc': 'RTC couldn\'t connect (@code). Please check your internet connection.',

      // Message errors
      'error.message.timestamp': 'A timestamp for your message could not be generated.',
      'error.message.empty': 'Your message is empty, please add some content to send it.',
      'error.message.loading': 'A message is still waiting to be sent, please wait for it to finish.',
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
