import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/app/video_settings.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class PublicationController extends GetxController {
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
      if (controller.members[SpaceMemberController.ownId] == null) {
        sendLog("local participant is null, this needs further investigation");
        return;
      }
      final participant = controller.members[SpaceMemberController.ownId]!.participant.value as LocalParticipant;
      if (newMuted) {
        participant.audioTrackPublications.firstOrNull?.mute();
      }
      _refreshState();
    }
  }

  /// Set a new microphone
  void refreshMicrophone(String deviceName) async {
    if (SpacesController.livekitRoom == null) {
      return;
    }
    String? deviceId = await getMicrophone(deviceName);

    // Check if there is one
    if (deviceId == null) {
      sendLog("couldn't find microphone to refresh to");
      return;
    }
    SpacesController.livekitRoom!.localParticipant!.audioTrackPublications.first.track!.setDeviceId(deviceId);
  }

  /// Get the device id from a microphone
  Future<String?> getMicrophone(String deviceName) async {
    String? deviceId;
    final list = await Hardware.instance.enumerateDevices(type: "audioinput");
    for (var device in list) {
      if (device.label == deviceName) {
        deviceId = device.deviceId;
      }
    }

    return deviceId;
  }

  void _refreshState() async {
    spaceConnector.sendAction(Message("update", <String, dynamic>{
      "muted": muted.value,
      "deafened": deafened.value,
    }));
  }

  //* Video
  final videoLoading = false.obs;
  final videoEnabled = false.obs;

  void setVideoEnabled(bool newVideoEnabled) async {
    videoLoading.value = true;
    if (_connected) {
      try {
        final controller = Get.find<SpaceMemberController>();
        final setCamera = Get.find<SettingController>().settings[VideoSettings.camera]!.getOrNull();
        if (newVideoEnabled) {
          final device = await _getDevice(setCamera ?? "hi");
          await SpacesController.livekitRoom?.localParticipant!.setCameraEnabled(
            true,
            cameraCaptureOptions: CameraCaptureOptions(
              deviceId: device?.deviceId,
            ),
          );
        } else {
          await SpacesController.livekitRoom?.localParticipant!.setCameraEnabled(false);
        }
        controller.members[SpaceMemberController.ownId]!.isVideo.value = newVideoEnabled;
        videoEnabled.value = newVideoEnabled;
      } catch (e) {
        sendLog("CAMERA ERROR $e");
      }
    }
    videoLoading.value = false;
  }

  Future<MediaDevice?> _getDevice(String label) async {
    final list = await Hardware.instance.enumerateDevices(type: "videoinput");
    return list.firstWhereOrNull((element) => element.label == label);
  }

  //* Screen share
  final screenshareLoading = false.obs;
  final screenshareEnabled = false.obs;

  void setScreenshareEnabled(bool newScreenshareEnabled, {ScreenShareCaptureOptions? options}) async {
    videoLoading.value = true;
    if (_connected) {
      try {
        final controller = Get.find<SpaceMemberController>();
        if (newScreenshareEnabled) {
          await SpacesController.livekitRoom?.localParticipant!.setScreenShareEnabled(true, screenShareCaptureOptions: options);
        } else {
          await SpacesController.livekitRoom?.localParticipant!.setScreenShareEnabled(false);
        }
        controller.members[SpaceMemberController.ownId]!.isScreenshare.value = newScreenshareEnabled;
        screenshareEnabled.value = newScreenshareEnabled;
      } catch (e) {
        sendLog("SCREEN SHARE ERROR $e");
      }
    }
    videoLoading.value = false;
  }

  void onConnect() async {
    // Enforce defaults
    final settingController = Get.find<SettingController>();
    deafened.value = false;

    // Set settings
    if (!configDisableRust) {
      await api.setTalkingAmplitude(amplitude: settingController.settings[AudioSettings.microphoneSensitivity]!.getOr(0.0));
      await api.setInputDevice(id: settingController.settings[AudioSettings.microphone]!.getValue());
    }
    _connected = true;
  }

  void disconnect() {
    _connected = false;
  }
}
