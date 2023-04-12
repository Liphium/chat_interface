import 'dart:async';

import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/sensitvity_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class MicrophoneController extends GetxController {

  // Microphone status
  final microphone = true.obs;
  final microphoneLoading = false.obs;
  StreamSubscription<dynamic>? subscription, sensitivitySubscription;

  LocalTrackPublication<LocalAudioTrack>? _pub;

  void setMicrophone(bool value) async {
    microphone.value = value;
    microphoneLoading.value = true;
    CallController controller = Get.find();

    if(microphone.value) {
      
      // If microphone is turned on, publish track
      if(subscription == null) {
        await setupTracks(controller);
      } else {
        await controller.room.value.localParticipant!.audioTracks[0].track!.unmute();
      }

    } else {

      // If microphone is turned off, mute track
      await controller.room.value.localParticipant!.audioTracks[0].track!.mute();
    }

    microphoneLoading.value = false;
  }

  Future<void> setupTracks(CallController controller) async {
    SettingController settingController = Get.find();

    // Publish microphone track (if turned on)
    if(microphone.value) {
      await _publishMicrophone(settingController.settings["audio.microphone"]!.getValue(), controller);

      // Listen for changes
      subscription = settingController.settings["audio.microphone"]!.value.listen((value) async {
        await _publishMicrophone(value, controller);
      });
    }

    // Listen for sensitivity changes
    sensitivitySubscription = Get.find<SensitivityController>().talking.listen((value) async {
      if(!microphone.value) return; // If microphone is turned off, don't change status

      if(value) {
        await controller.room.value.localParticipant!.audioTracks[0].track!.enable();
      } else {
        await controller.room.value.localParticipant!.audioTracks[0].track!.disable();
      }
    });
  }

  // Cancels all subscriptions
  void endCall() {
    sensitivitySubscription?.cancel();
    sensitivitySubscription = null;
    
    subscription?.cancel();
    subscription = null;
  }

  /// Publishes the microphone track
  Future<void> _publishMicrophone(String device, [CallController? callController]) async {
    CallController controller = callController ?? Get.find();

    // Check if there is already track
    if(controller.room.value.localParticipant!.hasAudio) {
      List<MediaDevice> devices = await Hardware.instance.audioInputs();
      Hardware.instance.selectedAudioInput = devices.firstWhere((element) => element.label == device);

      // Change track
      await _pub!.track!.setDeviceId(device);
    } else {

      // Create new track
      final track = await LocalAudioTrack.create(AudioCaptureOptions(
        deviceId: device,
      ));

      _pub = await controller.room.value.localParticipant!.publishAudioTrack(
        track, 
      );
    }

    return;
  }

}