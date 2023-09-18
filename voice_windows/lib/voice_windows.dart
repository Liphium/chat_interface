
import 'voice_windows_platform_interface.dart';

class VoiceWindows {
  Future<String?> getPlatformVersion() {
    return VoiceWindowsPlatform.instance.getPlatformVersion();
  }
}
