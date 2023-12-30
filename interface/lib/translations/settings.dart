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
      'settings.colors': 'Colors',
      'settings.call_app': 'Call appearance',
      'settings.requests': 'Friend requests',
      'settings.encryption': 'Encryption',
      'settings.spaces': 'Spaces',
      'settings.files': 'Files',
      'settings.invites': 'Invites',
      'settings.invites.title': 'You have @count invites left.',

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

      // Theme settings
      'theme.presets': 'Presets',
      'theme.default_dark': 'Advanched Dark',
      'theme.default_light': 'Advanched Light',
      'theme.winter': 'Winter',
      'theme.custom': 'Create your own',
      'theme.custom.title': 'Custom theme',
      'custom.primary_hue': 'Primary hue',
      'custom.secondary_hue': 'Secondary hue',
      'custom.base_saturation': 'Base saturation',
      'custom.theme_mode': 'Theme brightness',
      'custom.dark': 'Dark',
      'custom.light': 'Light',
      'custom.background_mode': 'What color should the background have?',
      'custom.none': 'None',
      'custom.colored': 'Primary color',
      'theme.apply': 'Apply your theme',

      // File settings
      'auto_download.images': 'Automatically download images',
      'auto_download.videos': 'Automatically download videos',
      'auto_download.audio': 'Automatically download audio',
      'settings.file.auto_download.types': 'Types of files to automatically download',
      'settings.file.max_size': 'Maximum file size for automatic downloads',
      'settings.file.max_size.description': 'Files larger than this will not be downloaded automatically.',
      'settings.file.cache': 'File cache',
      'settings.file.cache.description': 'The file cache stores all files that have been automatically downloaded. This includes profile pictures and all other data you\'ve selected above. When it is full old files will automatically be deleted. In the future you might even be able to turn this off. You can select the size of it with the slider below.',
      'settings.file.mb': 'MB',

      // Data settings
      'settings.data.profile_picture': 'Profile picture',
      'settings.data.profile_picture.select': 'Now just zoom and move your image into the perfect spot! So it makes your beauty shine, if you even have any...',
      'settings.data.profile_picture.requirements': 'Can only be a JPEG or PNG and can\'t be larger than 10 MB.',
      'settings.data.profile_picture.remove': 'Remove profile picture',
      'settings.data.profile_picture.remove.confirm': 'Are you sure you want to remove your profile picture?',
      'settings.data.permissions': 'Permissions',
      'settings.data.permissions.description': 'If you don\'t know what this is, it\'s fine. This is just data from the server that we can ask you for in case of problems. Here\'s which permissions you have:',

      // Invite settings (this is mostly alpha only)
      'settings.invites.description': "Invites are a token required for creating an account on the chat app. If you want one of your friends to be on here, send them an invite! They are distributed randomly in waves to prevent an influx of too many new users at once and also guarantee that the new users getting in are actually your friends.",
      'settings.invites.generate': 'Generate invite',
      'settings.invites.generated': 'Invite generated! It was copied to your clipboard.',
      'settings.invites.history': 'History',
      'settings.invites.history.description': 'Here are all the invites you already generated. Hover over them to see the token.',
      'settings.invites.history.empty': 'You haven\'t generated any invites yet or they have all been redeemed.',

      // Spaces settings
      'game.music': 'Play music in Game Mode',
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
      'settings.colors': 'Farben',
      'settings.call_app': 'Anrufe',
      'settings.requests': 'Freundschaftsanfragen',
      'settings.encryption': 'Verschlüsselung',
      'settings.spaces': 'Spaces',
      'settings.files': 'Dateien',
      'settings.invites': 'Einladungen',
      'settings.invites.title': 'Du hast @count Einladungen übrig.',

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

      // File settings
      'auto_download.images': 'Bilder automatisch herunterladen',
      'auto_download.videos': 'Videos automatisch herunterladen',
      'auto_download.audio': 'Audio automatisch herunterladen',
      'settings.file.auto_download.types': 'Dateitypen, die automatisch heruntergeladen werden sollen',
      'settings.file.max_size': 'Maximale Dateigröße für automatische Downloads',
      'settings.file.max_size.description': 'Dateien, die größer sind, werden nicht automatisch heruntergeladen.',
      'settings.file.cache': 'Dateicache',
      'settings.file.cache.description': 'Der Dateicache speichert alle Dateien, die automatisch heruntergeladen wurden. Dazu gehören Profilbilder und alle anderen Daten, die du oben ausgewählt hast. Wenn er voll ist, werden alte Dateien automatisch gelöscht. In Zukunft kannst du ihn vielleicht sogar ausschalten. Du kannst die Größe mit dem Regler unten auswählen.',
      'settings.file.mb': 'MB',

      // Theme settings
      'theme.presets': 'Vorlagen',
      'theme.default_dark': 'Dunkel',
      'theme.default_light': 'Hell',
      'theme.winter': 'Winter',
      'theme.custom': 'Erstelle dein eigenes',
      'theme.custom.title': 'Eigenes Design',
      'custom.primary_hue': 'Primärfarbe',
      'custom.secondary_hue': 'Sekundärfarbe',
      'custom.base_saturation': 'Sättigung',
      'custom.theme_mode': 'Helligkeit',
      'custom.dark': 'Dunkel',
      'custom.light': 'Hell',
      'custom.background_mode': 'Welche Farbe soll der Hintergrund haben?',
      'custom.none': 'Keine',
      'custom.colored': 'Primärfarbe',
      'theme.apply': 'Design anwenden',

      // Data settings
      'settings.data.profile_picture': 'Profilbild',
      'settings.data.profile_picture.select': 'Wähle dein neuestes Meme aus, damit jeder sehen kann, wie cool du bist!',
      'settings.data.profile_picture.requirements': 'Kann nur ein JPEG oder PNG sein und darf nicht größer als 10 MB sein.',
      'settings.data.profile_picture.remove': 'Profilbild entfernen',
      'settings.data.profile_picture.remove.confirm': 'Bist du sicher, dass du dein Profilbild entfernen möchtest?',
      'settings.data.permissions': 'Berechtigungen',
      'settings.data.permissions.description': 'Falls du nicht weißt, was das hier ist, ist es nicht schlimm. Das hier sind einfach nur Daten vom Server nach denen wir dich im Fall von Problemen fragen können. Hier sind deine Berechtigungen:',

      // Invite settings (this is mostly alpha only)
      'settings.invites.description': "Einladungen sind ein Token, der zum Erstellen eines Kontos in der Chat-App erforderlich ist. Wenn du willst, dass einer deiner Freunde hier ist, schick ihm eine Einladung! Sie werden zufällig in Wellen verteilt, um einen Zustrom von zu vielen neuen Benutzern auf einmal zu verhindern und garantieren auch, dass die neuen Benutzer, die hereinkommen, tatsächlich deine Freunde sind.",
      'settings.invites.generate': 'Einladung generieren',
      'settings.invites.generated': 'Einladung generiert! Sie wurde in deine Zwischenablage kopiert.',
      'settings.invites.history': 'Verlauf',
      'settings.invites.history.description': 'Hier sind alle Einladungen, die du bereits generiert hast. Halte den Mauszeiger darüber, um den Token zu sehen.',
      'settings.invites.history.empty': 'Du hast noch keine Einladungen generiert oder sie wurden alle eingelöst.',

      // Spaces settings
      'game.music': 'Musik im Spielmodus abspielen',
    }
  };
}