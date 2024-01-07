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
          'select': 'Select',
          'zoom': 'Zoom',
          'x': 'X',
          'y': 'Y',
          'close': 'Close',
          'username': 'Username',
          'password': 'Password',
          'email': 'Email',
          'under.dev': 'This featue is still under development. Sorry for the inconvenience. Please contact support if this is something important.',

          // Time TODO: Differentiate between PM and AM
          'message.time': '@hour:@minute',
          'time.yesterday': 'Yesterday',
          'time.today': 'Today',
          'time': '@month/@day/@year',
        },

        //* German
        'de_DE': {
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
          'under.dev': 'Dieses Feature ist noch in Entwicklung. Sorry für die Unannehmlichkeiten. Bitte kontaktiere den Support, wenn es um etwas Wichtiges geht.',

          // Time
          'message.time': '@hour:@minute',
          'time.yesterday': 'Gestern',
          'time.today': 'Heute',
          'time': '@day.@month.@year',
        }
      };
}
