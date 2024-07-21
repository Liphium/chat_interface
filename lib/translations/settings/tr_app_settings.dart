import 'package:get/get.dart';

class AppSettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        //* English US
        'en_US': {
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

          // Tabletop settings
          'settings.tabletop.decks': 'Decks',
          'settings.tabletop.decks.error':
              'An error occurred while loading your decks. This is probably something you\'ll need to report to us or it\'s just your connection. You can also try to see if there\'s a new version of the app available or try again later.',
          'settings.tabletop.decks.limit': 'Decks (@count/@limit)',
          'decks.description': 'Decks allow you to instantly add a whole bunch of cards to a tabletop session. If you have a pack of cards you want to use often, create a deck for it!',
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
          'tabletop.general.color': 'The color of your cursor',
          'tabletop.general.color.description': 'This will be the color everyone sees when you are selecting something or moving your cursor.',

          // Camera settings
          'video.camera.device': 'Select a camera',
          'video.camera.preview': 'Camera preview',
          'video.camera.preview.start': 'Start camera preview',

          // Logging settings
          'logging.amount.desc': 'Amount of logs to keep in the history',
          'logging.launch': 'Open log folder',
        },
      };
}
