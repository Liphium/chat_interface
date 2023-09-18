import 'package:flutter_test/flutter_test.dart';
import 'package:voice_windows/voice_windows.dart';
import 'package:voice_windows/voice_windows_platform_interface.dart';
import 'package:voice_windows/voice_windows_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVoiceWindowsPlatform
    with MockPlatformInterfaceMixin
    implements VoiceWindowsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VoiceWindowsPlatform initialPlatform = VoiceWindowsPlatform.instance;

  test('$MethodChannelVoiceWindows is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVoiceWindows>());
  });

  test('getPlatformVersion', () async {
    VoiceWindows voiceWindowsPlugin = VoiceWindows();
    MockVoiceWindowsPlatform fakePlatform = MockVoiceWindowsPlatform();
    VoiceWindowsPlatform.instance = fakePlatform;

    expect(await voiceWindowsPlugin.getPlatformVersion(), '42');
  });
}
