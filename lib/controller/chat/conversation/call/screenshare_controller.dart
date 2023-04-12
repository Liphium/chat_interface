import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class ScreenshareController extends GetxController {

  final pub = Rx<LocalTrackPublication<LocalVideoTrack>?>(null);
  final track = Rx<LocalVideoTrack?>(null);

  final isSharing = false.obs;
  final sharingLoading = false.obs;

  void startSharing() async {
    sharingLoading.value = true;
    CallController controller = Get.find();

    try {
      final source = await showDialog<DesktopCapturerSource>(
        context: Get.context!,
        builder: (context) => ScreenSelectDialog(),
      );

      if (source == null) {
        print('cancelled screenshare');
        return;
      }

      print('DesktopCapturerSource: ${source.id}');
      track.value = await LocalVideoTrack.createScreenShareTrack(
        ScreenShareCaptureOptions(
          sourceId: source.id,
          maxFrameRate: 30.0,
        ),
      );

      pub.value = await controller.room.value.localParticipant!.publishVideoTrack(
        track.value!,
        publishOptions: const VideoPublishOptions(
          videoEncoding: VideoEncoding(
            maxFramerate: 30,
            maxBitrate: 3 * 1000 * 1000,
          ),
          simulcast: false
        )  
      );

    } catch (e) {
      print('could not publish screen sharing: $e');
    }
    isSharing.value = true;

    sharingLoading.value = false;
  }

  void stopSharing() async {
    sharingLoading.value = true;
    CallController controller = Get.find();

    isSharing.value = false;
    pub.value = null;
    track.value = null;
    await controller.room.value.localParticipant!.setScreenShareEnabled(false);
    sharingLoading.value = false;
  }

}