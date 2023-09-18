import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'voice_windows_method_channel.dart';

abstract class VoiceWindowsPlatform extends PlatformInterface {
  /// Constructs a VoiceWindowsPlatform.
  VoiceWindowsPlatform() : super(token: _token);

  static final Object _token = Object();

  static VoiceWindowsPlatform _instance = MethodChannelVoiceWindows();

  /// The default instance of [VoiceWindowsPlatform] to use.
  ///
  /// Defaults to [MethodChannelVoiceWindows].
  static VoiceWindowsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VoiceWindowsPlatform] when
  /// they register themselves.
  static set instance(VoiceWindowsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
