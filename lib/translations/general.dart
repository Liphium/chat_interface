import 'package:get/get.dart';

class GeneralTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
          // Actions
          'learn_more': 'Learn more',
          'offline': 'Offline',
          'loading': 'Loading..',
          'preparing': 'Preparing..',
          'rendering': 'Rendering..',
          'success': 'Success',
          'create': 'Create',
          'ok': 'Okay',
          'edit': 'Edit',
          'copy': 'Copy',
          'retry': 'Retry',
          'back': 'Back',
          'no.got': 'No, you got me',
          'yeah': 'Yeah',
          'yes': 'Yes',
          'accept': 'Accept',
          'no': 'No',
          'change': 'Change',
          'save': 'Save',
          'view': 'View',
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
          'username.description': 'Your username can only contain lowercase characters, numbers and "_" or "-".',
          'display_name': "Display name",
          'display_name.description': 'Your display name is the name everyone sees. No special requirements.',
          'password': 'Password',
          'password.current': 'Current password',
          'invite': 'Invite',
          'email': 'Email',
          'code': 'Code',
          'under.dev': 'This feature is still under development. Sorry for the inconvenience.',
          'no.friends': 'You have no friends yet. If you want to add some, you can do that in the friends page.',
          'open.friends': 'Open friends page',
          'reset': 'Reset',
          'app.settings': 'App settings',
          'spaces': 'Spaces',
          'page_switcher': 'Page @count/@max',
          'rank': 'Rank',
          'liphium_address': 'Your Liphium address',

          // Placeholder
          'placeholder.domain': 'example.com',

          // Time TODO: Differentiate between PM and AM
          'message.time': '@hour:@minute',
          'time.yesterday': 'Yesterday',
          'time.today': 'Today',
          'time': '@day/@month/@year',
          'general_time': '@day/@month/@year @hour:@minute',

          // Log out thing
          'log_out': 'Log out',
          'log_out.dialog':
              'This will delete all the data on this device. If you don\'t have your keys as a file or on another logged in device, you will not be able to recover your account. Are you sure you want to log out?',
          'log_out.delete_files': 'Delete files',

          // File things
          'file.uploading': 'Uploading @index of @total..',
          'file.links.title': 'Unknown location found',
          'file.links.description':
              'You are trying to connect to a town at @domain. This could potentially lead to your IP address or personal information being exposed. Do you want to add @domain to your list of trusted towns?',

          // For specifically adding the links to GIFs or images on a different server
          'file.images.trust.title': 'Add to trusted links',
          'file.images.trust.description':
              'If you add @domain to your list of trusted providers, this means they will be able to see your IP address or other personal information that may be exposed using a web request. Do you want to add @domain to your list of trusted providers?',

          // Context menu
          'context_menu.cut': 'Cut',
          'context_menu.copy': 'Copy',
          'context_menu.paste': 'Paste',
          'context_menu.selectAll': 'Select all',
          'context_menu.share': 'Share',
          'context_menu.delete': 'Delete',
          'context_menu.custom': 'Custom',

          // Tray icon context menu
          'tray.show_window': 'Show window',
          'tray.exit_app': 'Exit app',
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
