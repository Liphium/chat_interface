import 'package:get/get.dart';

class GeneralTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Actions
          'success': 'Success',
          'create': 'Create',
          'ok': 'Okay',
          'retry': 'Retry',
          'back': 'Back',
          'no.got': 'No, you got me',
          'yeah': 'Yeah',
          'yes': 'Yes',
          'no': 'No',
          'change': 'Change',
          'save': 'Save',
          'delete': 'Delete',
          'cancel': 'Cancel',
          'remove': 'Remove',
          'removed': 'Removed',
          'add': 'Add',
          'select': 'Select',
          'search': 'Search',
          'zoom': 'Zoom',
          'x': 'X',
          'y': 'Y',
          'close': 'Close',
          'open': 'Open',
          'username': 'Username',
          'password': 'Password',
          'password.current': 'Current password',
          'invite': 'Invite',
          'email': 'Email',
          'code': 'Code',
          'under.dev': 'This featue is still under development. Sorry for the inconvenience. Please contact support if this is something important.',
          'no.friends': 'You have no friends yet. If you want to add some, you can do that in the friends page.',
          'open.friends': 'Open friends page',

          // Time TODO: Differentiate between PM and AM
          'message.time': '@hour:@minute',
          'time.yesterday': 'Yesterday',
          'time.today': 'Today',
          'time': '@month/@day/@year',

          // Log out thing
          'log_out': 'Log out',
          'log_out.dialog':
              'This will delete all the data on this device. If you don\'t have your keys as a file or on another logged in device, you will not be able to recover your account. Are you sure you want to log out?',
          'log_out.delete_files': 'Delete files',

          // Uploading
          'file.uploading': 'Uploading @index of @total..',
        },

        //* German
        'de_DE': {
          /*
          // Actions
          'success': 'Erfolg',
          'create': 'Erstellen',
          'ok': 'Verstanden',
          'retry': 'Nochmal versuchen',
          'back': 'Zurück',
          'no.got': 'Nein, sorry',
          'yeah': 'Natürlich',
          'yes': 'Ja',
          'no': 'Nein',
          'change': 'Ändern',
          'save': 'Speichern',
          'delete': 'Löschen',
          'select': 'Auswählen',
          'zoom': 'Zoom',
          'x': 'X',
          'y': 'Y',
          'close': 'Schließen',
          'username': 'Benutzername',
          'password': 'Passwort',
          'email': 'Email',
          'invite': 'Einladung',
          'code': 'Code',
          'under.dev': 'Dieses Feature ist noch in Entwicklung. Sorry für die Unannehmlichkeiten. Bitte kontaktiere den Support, wenn es um etwas Wichtiges geht.',

          // Time
          'message.time': '@hour:@minute',
          'time.yesterday': 'Gestern',
          'time.today': 'Heute',
          'time': '@day.@month.@year',
          */
        }
      };
}
