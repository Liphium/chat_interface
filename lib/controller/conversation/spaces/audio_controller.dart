import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class AudioController extends GetxController {
  //* Output
  final deafenLoading = false.obs;
  final deafened = false.obs;
  bool _connected = false;

  void setDeafened(bool newOutput) async {
    deafened.value = newOutput;
    if (_connected) {
      final controller = Get.find<SpaceMemberController>();
      controller.members[SpaceMemberController.ownId]!.isDeafened.value = newOutput;
      controller.members[SpaceMemberController.ownId]!.isSpeaking.value = newOutput ? false : controller.members[SpaceMemberController.ownId]!.isSpeaking.value;
      if (controller.members[SpaceMemberController.ownId]!.participant.value != null) {
        if (newOutput) {
          // Stop all audio and unsubscribe from tracks
          for (var remote in SpacesController.livekitRoom!.remoteParticipants.values) {
            for (var track in remote.audioTrackPublications) {
              if (track.kind != TrackType.AUDIO) continue;
              track.unsubscribe();
            }
          }
        } else {
          // Start all audio and subscribe to tracks again
          for (var remote in SpacesController.livekitRoom!.remoteParticipants.values) {
            for (var track in remote.audioTrackPublications) {
              if (track.kind != TrackType.AUDIO) continue;
              track.subscribe();
            }
          }
        }
      }
      _refreshState();
    }
  }

  //* Input
  final muteLoading = false.obs;
  final muted = false.obs;

  void setMuted(bool newMuted) async {
    muted.value = newMuted;
    if (_connected) {
      final controller = Get.find<SpaceMemberController>();
      controller.members[SpaceMemberController.ownId]!.isMuted.value = newMuted;
      controller.members[SpaceMemberController.ownId]!.isSpeaking.value = newMuted ? false : controller.members[SpaceMemberController.ownId]!.isSpeaking.value;
      final participant = controller.members[SpaceMemberController.ownId]!.participant.value as LocalParticipant;
      if (newMuted) {
        participant.audioTrackPublications.firstOrNull?.mute();
      }
      _refreshState();
    }
  }

  void _refreshState() async {
    spaceConnector.sendAction(Message("update", <String, dynamic>{
      "muted": muted.value,
      "deafened": deafened.value,
    }));
  }

  void onConnect() async {
    // Enforce defaults
    final settingController = Get.find<SettingController>();
    await api.setDeafen(deafened: false);
    await api.setSilentMute(silentMute: false);
    deafened.value = false;

    // Set settings
    await api.setTalkingAmplitude(amplitude: settingController.settings[SpeechSettings.microphoneSensitivity]!.getOr(0.0));
    await api.setInputDevice(id: settingController.settings[SpeechSettings.microphone]!.getValue());
    await api.setOutputDevice(id: settingController.settings[SpeechSettings.output]!.getValue());
    _connected = true;

    // Set mute
    final startMuted = settingController.settings[SpeechSettings.startMuted]!.getValue() as bool;
    await api.setMuted(muted: startMuted);
    await Future.delayed(500.milliseconds);
    setMuted(startMuted);
  }

  void disconnect() {
    _connected = false;
  }
}
