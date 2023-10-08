import 'package:get/get.dart';

class SettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {

    //* English US
    'en_US': {
      // Categories
      'settings.tab.account': 'Account',
      'settings.tab.appearance': 'Appearance',
      'settings.tab.app': 'App',
      'settings.tab.privacy': 'Privacy',
      'settings.data': 'Data',
      'settings.profile': 'Profile',
      'settings.security': 'Security',
      'settings.devices': 'Devices',
      'settings.video': 'Video',
      'settings.audio': 'Audio',
      'settings.notifications': 'Notifications',
      'settings.language': 'Language',
      'settings.theme': 'Theme',
      'settings.call_app': 'Call appearance',
      'settings.requests': 'Friend requests',
      'settings.encryption': 'Encryption',

      // Audio settings
      'audio.device': 'Select a device',
      'audio.device.default': "If you don't know what to select here, the default is probably fine:",
      'audio.device.default.button': 'Use system default',
      'audio.microphone': 'Microphone',
      'audio.microphone.device': 'Or you just select one of these devices (the green verified indicator tries detecting the best microphone):',
      'audio.microphone.muted': 'Start muted in Spaces',
      'audio.microphone.sensitivity': 'Microphone sensitivity',
      'audio.microphone.sensitivity.text': 'The green line is your current talking volume. Drag the slider to the point where you would like others to start hearing you.',
      'audio.output': 'Output',
      'audio.output.device': 'Or you just select one of these devices:',
    },

    //* German
    'de_DE': {
      // Categories
      'settings.tab.account': 'Konto',
      'settings.tab.appearance': 'Aussehen',
      'settings.tab.app': 'App',
      'settings.tab.privacy': 'Privatsphäre',
      'settings.data': 'Daten',
      'settings.profile': 'Profil',
      'settings.security': 'Sicherheit',
      'settings.devices': 'Geräte',
      'settings.video': 'Video',
      'settings.audio': 'Audio',
      'settings.notifications': 'Benachrichtigungen',
      'settings.language': 'Sprache',
      'settings.theme': 'Design',
      'settings.call_app': 'Anrufe',
      'settings.requests': 'Freundschaftsanfragen',
      'settings.encryption': 'Verschlüsselung',

      // Audio settings
      'audio.device': 'Wähle ein Gerät aus',
      'audio.device.default': 'Wenn du nicht weißt, was du hier auswählen sollst, ist oft das Standardgerät in Ordnung:',
      'audio.device.default.button': 'Systemstandard verwenden',
      'audio.microphone': 'Mikrofon',
      'audio.microphone.device': 'Oder du wählst einfach eines dieser Geräte aus (der grüne Verifizierungsindikator steht für das beste Mikrofon):',
      'audio.microphone.muted': 'In einem Space stummgeschaltet starten',
      'audio.microphone.sensitivity': 'Mikrofonempfindlichkeit',
      'audio.microphone.sensitivity.text': 'Die grüne Linie ist deine aktuelle Lautstärke. Ziehe den Regler an die Stelle, an der andere dich hören sollen.',
      'audio.output': 'Ausgabe',
      'audio.output.device': 'Oder du wählst einfach eines dieser Geräte aus:',
    }
  };
}