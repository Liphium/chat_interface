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

  void setMicrophone(bool value) async {
    microphone.value = value;
    microphoneLoading.value = true;
    CallController controller = Get.find();

    if(microphone.value) {
      
      // If microphone is turned on, publish track
      if(subscription == null) {
        await setupTracks(controller);
      } else {
        await controller.room.value.localParticipant!.setMicrophoneEnabled(true);
      }

    } else {

      // If microphone is turned off, mute track
      await controller.room.value.localParticipant!.setMicrophoneEnabled(false);
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
        Get.find<SensitivityController>().restart();
      });
    }

    // Listen for sensitivity changes
    sensitivitySubscription = Get.find<SensitivityController>().talking.listen((value) async {
      if(!microphone.value) return; // If microphone is turned off, don't change status

      if(value) {
        await controller.room.value.localParticipant!.audioTracks[0].track!.unmute();
      } else {
        await controller.room.value.localParticipant!.audioTracks[0].track!.mute();
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

      // Change input device
      await controller.room.value.setAudioInputDevice(await _getDevice(device));
    } else {

      await controller.room.value.setAudioInputDevice(await _getDevice(device));
      await controller.room.value.localParticipant!.setMicrophoneEnabled(true);
    }

    return;
  }

  Future<MediaDevice> _getDevice(String device) async {
    final devices = await Hardware.instance.audioInputs();
    return devices.firstWhere((element) => element.label == device);
  }

}