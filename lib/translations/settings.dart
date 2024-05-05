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
          'settings.tab.security': 'Security',
          'settings.data': 'Data',
          'settings.profile': 'Profile',
          'settings.security': 'Security',
          'settings.devices': 'Devices',
          'settings.camera': 'Camera',
          'settings.audio': 'Audio',
          'settings.notifications': 'Notifications',
          'settings.language': 'Language',
          'settings.colors': 'Colors',
          'settings.call_app': 'Call appearance',
          'settings.requests': 'Friend requests',
          'settings.encryption': 'Encryption',
          'settings.spaces': 'Spaces',
          'settings.tabletop': 'Tabletop',
          'settings.chat': 'Chat',
          'settings.files': 'Files',
          'settings.invites': 'Invites',
          'settings.trusted_links': 'Trusted Links',
          'settings.invites.title': 'You have @count invites left.',
          'settings.experimental': 'Experimental',

          // Audio settings
          'audio.microphone.windows_warning':
              'Windows is a little cunt and might decrease the volume of your system sounds while you are talking, so we advise that you either set Sound -> Communication to "Do nothing" in your System Control Panel or just click the button below. Why does this exist again?',
          'audio.device': 'Select a device',
          'audio.device.default': "If you don't know what to select here, the default is probably fine:",
          'audio.device.default.button': 'Use system default',
          'audio.microphone': 'Microphone',
          'audio.microphone.device': 'Or you just select one of these devices (the green verified indicator tries detecting the best microphone):',
          'audio.device.custom': 'Or choose one of the following devices:',
          'audio.microphone.muted': 'Start muted in Spaces',
          'audio.microphone.sensitivity': 'Microphone sensitivity',
          'audio.microphone.sensitivity.text': 'The green line is your current talking volume. Drag the slider to the point where you would like others to start hearing you.',
          'audio.microphone.sensitivity.automatic': 'Automatic',
          'audio.microphone.sensitivity.manual': 'Manual',
          'audio.microphone.sensitivity.audio_detector': 'This thing shows if you are talking or not, if it\'s colored we would be transmitting your voice.',
          'audio.microphone.processing': 'Microphone processing',
          'audio.microphone.processing.text': 'When changing any of these settings, please rejoin the space to apply them.',
          'audio.microphone.echo_cancellation': 'Echo cancellation',
          'audio.microphone.noise_suppression': 'Noise suppression',
          'audio.microphone.auto_gain_control': 'Auto gain control',
          'audio.microphone.typing_noise_detection': 'Typing noise detection',
          'audio.microphone.high_pass_filter': 'High-pass filter',
          'audio.output': 'Output',
          'audio.output.device': 'Or you just select one of these devices:',

          // Theme settings
          'theme.presets': 'Presets',
          'theme.default_dark': 'Default dark',
          'theme.default_light': 'Default light',
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
          'settings.file.cache.description':
              'The file cache stores all files that have been automatically downloaded. This includes profile pictures and all other data you\'ve selected above. When it is full old files will automatically be deleted. You can select the size with the slider below or make it unlimited.',
          'settings.file.cache_type.unlimited': 'Unlimited',
          'settings.file.cache_type.size': 'Size',
          'settings.file.mb': 'MB',
          'settings.file.live_share': 'Live Share',
          'settings.file.live_share.description':
              'This is an experimental feature that allows you to share files with one of your friends in real-time, up to any file size. This gives you a glimpse into the future of file sharing on Liphium. You can access this feature by clicking on the bolt icon in any direct message.',
          'files.live_share.experiment': 'Enable Live Share',

          // Data settings
          'settings.data.social': 'Social features',
          'settings.data.social.text':
              'Liphium\'s social features allow you to share things not just with your friends, but also with the people on your instance. You can chat with everyone, but therefore it\'s not encrypted, so we allow you to disable it.',
          'data.social': 'Enable social features',
          'settings.data.profile_picture': 'Profile picture',
          'settings.data.profile_picture.select': 'Now just zoom and move your image into the perfect spot! So it makes your beauty shine, if you even have any...',
          'settings.data.profile_picture.requirements': 'Can only be a JPEG or PNG and can\'t be larger than 10 MB.',
          'settings.data.profile_picture.remove': 'Remove profile picture',
          'settings.data.profile_picture.remove.confirm': 'Are you sure you want to remove your profile picture?',
          'settings.data.permissions': 'Permissions',
          'settings.data.permissions.description':
              'If you don\'t know what this is, it\'s fine. This is just data from the server that we can ask you for in case of problems. Here\'s which permissions you have:',
          'settings.data.account': 'Account data',
          'settings.data.password.description': 'We\'ll not show your password here. That would be stupid.',
          'settings.data.change_password.dialog': 'Let\'s make sure your account is secure again. All your devices (also this one) will be logged out after you click "Save".',
          'settings.data.email.description': 'Showing your email would be work. And I don\'t like that, you know.',
          'settings.data.log_out': 'Log out of your account',
          'settings.data.log_out.description':
              'If you log out of your account, we\'ll delete all your data from this device. This includes the keys we use to encrypt stuff on our servers. If you don\'t have these on another device, you will NEVER be able to recover your friends.',
          'settings.data.danger_zone': 'Danger zone',
          'settings.data.danger_zone.description':
              'Hello, and welcome down here! Hope you haven\'t come here to delete your account. If you have, you can do that here. But please don\'t. We\'ll miss you. :(',
          'settings.data.danger_zone.delete_account': 'Delete account',
          'settings.data.danger_zone.delete_account.confirm':
              'This is just a request and your actual data will be deleted in 30 days. We do this to make sure you didn\'t just accidentally click this button and that you are the actual owner of this account. Are you sure you want to delete your account?',
          'settings.data.change_name.dialog': 'Want to change your username? Just provide it below and we\'ll handle it for you.',
          'settings.data.change_display_name.dialog': 'Want to change your display name? We\'ll handle your request right here.',

          // Invite settings (this is mostly alpha only)
          'settings.invites.description':
              "Invites are a token required for creating an account on the chat app. If you want one of your friends to be on here, send them an invite! They are distributed randomly in waves to prevent an influx of too many new users at once and also guarantee that the new users getting in are actually your friends.",
          'settings.invites.generate': 'Generate invite',
          'settings.invites.generated': 'Invite generated! It was copied to your clipboard.',
          'settings.invites.history': 'History',
          'settings.invites.history.description': 'Here are all the invites you already generated. Hover over them to see the token.',
          'settings.invites.history.empty': 'You haven\'t generated any invites yet or they have all been redeemed.',

          // Spaces settings
          'game.music': 'Play music in Game Mode',

          // Tabletop settings
          'settings.tabletop.decks': 'Decks',
          'settings.tabletop.decks.error':
              'An error occurred while loading your decks. This is probably something you\'ll need to report to us or it\'s just your connection. You can also try to see if there\'s a new version of the app available or try again later.',
          'settings.tabletop.decks.limit': 'Decks (@count/@limit)',
          'decks.description':
              'Decks allow you to instantly add a whole bunch of cards to a tabletop session. If you have a pack of cards you want to use often, create a deck for it!',
          'decks.create': 'Create a new deck',
          'decks.dialog.delete.title': 'Delete deck',
          'decks.dialog.delete': 'Are you sure you want to delete this deck? Think about all the cards you\'ll lose!',
          'decks.dialog.new_name': 'Type a new name for your deck here. This won\'t delete the cards in it, it\'ll just change the name.',
          'decks.dialog.name': 'First of all, please give your deck a nice name. You know, something actually good.',
          'decks.dialog.name.placeholder': 'Deck name',
          'decks.dialog.name.error': 'Please make the name for your deck longer than 3 characters.',
          'decks.limit_reached': 'You have reached the maximum amount of decks you can create. Please delete one of your existing decks to create a new one.',
          'decks.cards': '@count cards',
          'decks.view_cards': 'View cards',
          'decks.cards.empty': 'This deck is empty. You can add cards to it by clicking the button above.',
          'settings.tabletop.general': 'General',
          'tabletop.general.framerate': 'Framerate',
          'tabletop.general.framerate.description': 'The framerate at which the table is rendered. This should be roughly equivalent to the refresh rate of your monitor.',
          'tabletop.general.framerate.unit': 'Hz',

          // Trusted links
          'links.warning':
              'This an advanced section. Changing the default behavior of the app might result in leaks of your data or other various things. Only change things here if you know what you\'re doing.',
          'links.locations': 'Settings for locations',
          'links.unsafe_sources': 'Allow accessing resources from unsafe locations (e.g. websites with HTTP)',
          'links.trusted_domains': 'Trusted domains',
          'links.trust_mode': 'Select which domains you want to trust.',
          'links.trust_mode.all': 'All domains',
          'links.trust_mode.list_verified': 'A verified list of providers',
          'links.trust_mode.list': 'A custom list of domains (defined below)',
          'links.trust_mode.none': 'No domains',
          'links.trusted_list': 'Here\'s the list of domains you trust.',
          'links.trusted_list.add': 'Add a trusted domain',
          'links.trusted_list.placeholder': 'liphium.app',
          'links.trusted_list.empty': 'You currently don\'t trust any domains.',

          // Camera settings
          'video.camera.device': 'Select a camera',
          'video.camera.preview': 'Camera preview',
          'video.camera.preview.start': 'Start camera preview',

          // Chat theme settings
          'appearance.chat.theme': 'Chat theme',
          'appearance.chat.theme.material': 'Material',
          'appearance.chat.theme.bubbles': 'Chat bubbles',
        },
      };
}
