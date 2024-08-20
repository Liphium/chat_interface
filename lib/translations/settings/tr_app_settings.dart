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
