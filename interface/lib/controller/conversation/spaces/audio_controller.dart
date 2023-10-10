import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/pages/settings/app/speech/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';

class AudioController extends GetxController {
  
  //* Output
  final deafenLoading = false.obs;
  final deafened = false.obs;
  bool _connected = false;

  void setDeafened(bool newOutput) async {
    await api.setDeafen(deafened: newOutput);
    deafened.value = newOutput;
    if(_connected) {
      final controller = Get.find<SpaceMemberController>();
      controller.members[controller.getClientId()]!.isDeafened.value = newOutput;
    }
  }

  //* Input
  final muteLoading = false.obs;
  final muted = false.obs;

  void setMuted(bool newMuted) async {
    await api.setMuted(muted: newMuted);
    muted.value = newMuted;
    if(_connected) {
      final controller = Get.find<SpaceMemberController>();
      controller.members[controller.getClientId()]!.isMuted.value = newMuted;
    }
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
    _connected = true;
  }

  void disconnect() {
    _connected = false;
  }
}