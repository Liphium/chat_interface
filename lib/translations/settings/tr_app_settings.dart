import 'package:get/get.dart';

class AppSettingsTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    //* English US
    'en_US': {
      // General settings
      'settings.general.notifications': 'Notifications',
      'settings.general.ringtone': 'Spaces ringtone',
      'settings.general.language': 'Choose the app language',
      'settings.general.ringtone.disabled':
          'The Spaces ringtone is currently disabled. It will be re-introduced when voice chat returns to Spaces some time in 2025. Together with Liphium Ring, but that\'s not even on the roadmap yet.',
      'notification_sounds.tooltip': 'This only plays the sound when your settings allow it to.',
      'notification_sounds.enabled': 'Enable notification sounds',
      'notification_sounds.do_not_disturb': 'Play notification sounds even when in do-not-disturb mode',
      'notification_sounds.only_when_tray': 'Only play notification sounds when minimized to tray',
      'ring.desc':
          'The ringtone will follow all settings from the notification sounds above. You can also make it so the ringtone still plays when Liphium is not minimized by using the settings below.',
      'ring.enable': 'Play a ring sound when being invited to a Space',
      'ring.ignore_tray': 'Also play a ring sound when Liphium is not minimized to tray',

      // Logging settings
      'logging.amount.desc': 'Amount of logs to keep in the history',
      'logging.launch': 'Open log folder',

      // Audio settings
      'settings.audio.microphone': 'Choose your microphone',
      'settings.audio.output_device': 'Choose your output device',
      'settings.audio.devices_empty': 'No devices found or still loading devices.',
      'settings.audio.activation_mode': 'Microphone activation mode',
      'settings.audio.activation_mode.desc':
          'When the square on the right is a bright color, your voice will be transmitted.',
      'microphone.mode.voice_activity': 'Detect when I speak',
      'microphone.mode.always_on': 'Always transmit my speech',
      'microphone.auto_activity': 'Automatically determine when I speak',
      'settings.audio.microphone.sensitivity.desc':
          'You will be heard by other people when your volume is over the threshold defined below.',
    },
  };
}
