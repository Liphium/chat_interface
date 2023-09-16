import 'package:chat_interface/controller/conversation/livekit/call_controller.dart';
import 'package:chat_interface/controller/conversation/livekit/call_member_controller.dart';
import 'package:chat_interface/controller/conversation/livekit/output_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

@Deprecated("LiveKit is no longer supported (will be used when we tackle the video call feature)")
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
        sharingLoading.value = false;
        return;
      }

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
      sendLog('could not publish screen sharing: $e');
    }
    isSharing.value = true;

    // Add to call
    controller.hasVideo.value = true;
    StatusController status = Get.find();
    Get.find<PublicationController>().screenshares[status.id.value] = Video(Get.find<CallMemberController>().members[status.id.value]!, pub.value!);

    sharingLoading.value = false;
  }

  void stopSharing() async {
    sharingLoading.value = true;
    CallController controller = Get.find();

    isSharing.value = false;
    pub.value = null;
    await track.value?.stop();
    track.value = null;
    await controller.room.value.localParticipant!.setScreenShareEnabled(false);
    sharingLoading.value = false;
  }

}