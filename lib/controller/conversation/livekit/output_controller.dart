import 'dart:async';

import 'package:chat_interface/controller/conversation/livekit/call_controller.dart';
import 'package:chat_interface/controller/conversation/livekit/call_member_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

@Deprecated("LiveKit is no longer supported (will be used when we tackle the video call feature)")
class PublicationController extends GetxController {

  // Output status
  final output = true.obs;
  final outputLoading = false.obs;

  final screenshares = <String, Video>{}.obs;
  final cameras = <String, Video>{}.obs;

  void changeOutputDevice(MediaDevice device) async {
    CallController controller = Get.find();

    // Change output device
    if(controller.livekit.value) {
      controller.room.value.setAudioOutputDevice(device);
    }

    Get.find<SettingController>().settings["audio.output"]!.setValue(device.label);
  }

  void subscribeToStreams(EventsListener<RoomEvent> listener) {

    // Listen for new audio tracks
    listener
      ..on<TrackPublishedEvent>((event) {

        if(event.publication.kind == TrackType.AUDIO) {

          // Subscribe to track
          if(output.value) {
            event.publication.subscribe();
          }
        } else if(event.publication.kind == TrackType.VIDEO) {
          Get.find<CallController>().hasVideo.value = true;

          // Parse id
          final id = event.participant.identity;

          // Subscribe to screenshare
          if(event.publication.isScreenShare) {

            // Subscribe if only one
            if(screenshares.isEmpty) {
              event.publication.subscribe();
            }

            screenshares[id] = Video(Get.find<CallMemberController>().members[id]!, event.publication as RemoteTrackPublication<RemoteVideoTrack>);
          } else {

            // Subscribe to camera
            cameras[id] = Video(Get.find<CallMemberController>().members[id]!, event.publication as RemoteTrackPublication<RemoteVideoTrack>);
            event.publication.subscribe();
          }
        }

      })

      // Listen for removed audio tracks
      ..on<TrackUnpublishedEvent>((event) {
        if(event.publication.kind == TrackType.AUDIO) {

          // Unsubscribe from track
          event.publication.unsubscribe();
        } else if(event.publication.kind == TrackType.VIDEO) {

          // Unsubscribe from screenshare/camera
          event.publication.unsubscribe();

          (event.publication.isScreenShare ? screenshares : cameras).remove(int.tryParse(event.participant.identity) ?? -1);

          if(screenshares.isEmpty && cameras.isEmpty) {
            Get.find<CallController>().hasVideo.value = false;
          }
        }
      });
  }

  void setOutput(bool speakers) async {
    output.value = speakers;
    CallController controller = Get.find();
    outputLoading.value = true;

    if(output.value) {

      // Unmute all tracks
      for(var participant in controller.room.value.participants.entries) {
        for(var track in participant.value.audioTracks) {
          if(!track.subscribed) {
            await track.subscribe();
          }
        }
      }
    } else {

      // Mute all tracks
      for(var participant in controller.room.value.participants.entries) {
        for(var track in participant.value.audioTracks) {
          if(track.subscribed) {
            await track.unsubscribe();
          }
        }
      }
    }

    outputLoading.value = false;
  }

  void subscribeToScreenshare(Video video) async {
    video.loading.value = true;
    if(video is RemoteTrackPublication) {
      if(video.publication.subscribed) {
        return;
      }
    }

    for(var ss in screenshares.values) {
      if(ss.publication is RemoteTrackPublication) {
        (ss.publication as RemoteTrackPublication).unsubscribe();
      }
    }

    if(video.publication is RemoteTrackPublication) {
      await (video.publication as RemoteTrackPublication).subscribe();
    }

    video.waitForTrack();
  }
}

class Video {
  final Member member;
  final TrackPublication<VideoTrack> publication;
  final loading = true.obs;

  Video(this.member, this.publication) {
    waitForTrack();
  }

  void waitForTrack() {

    // Wait for track to be ready
    Timer.periodic(1000.ms, (timer) {
      if(publication.track != null) {
        loading.value = false;
        timer.cancel();
      }
    });
  }

}