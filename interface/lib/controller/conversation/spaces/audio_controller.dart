import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/pages/settings/app/speech/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  
  //* Output
  final deafenLoading = false.obs;
  final deafened = false.obs;

  void setDeafened(bool newOutput) async {
    await api.setDeafen(deafened: newOutput);
    deafened.value = newOutput;
  }

  //* Input
  final muteLoading = false.obs;
  final muted = false.obs;

  void setMuted(bool newMuted) async {
    await api.setMuted(muted: newMuted);
    muted.value = newMuted;
  }

  void onConnect() {

    // Enforce defaults
    final settingController = Get.find<SettingController>();
    api.setMuted(muted: settingController.settings[SpeechSettings.startMuted]!.getValue() as bool);
    api.setDeafen(deafened: false);
    api.setSilentMute(silentMute: false);
    muted.value = settingController.settings[SpeechSettings.startMuted]!.getValue() as bool;
    deafened.value = false;

    // Set settings
    api.setTalkingAmplitude(amplitude: settingController.settings[SpeechSettings.microphoneSensitivity]!.getOr(0.0));
    api.setInputDevice(id: settingController.settings[SpeechSettings.microphone]!.getValue());
    api.setOutputDevice(id: settingController.settings[SpeechSettings.output]!.getValue());
  }

  void disconnect() {
  }
}