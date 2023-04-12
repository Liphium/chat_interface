import 'dart:async';

import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/call_member_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class PublicationController extends GetxController {

  // Output status
  final output = true.obs;
  final outputLoading = false.obs;

  final screenshares = <int, Screenshare>{}.obs;

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

          // Subscribe to screenshare
          if(event.publication.isScreenShare) {

            final id = int.tryParse(event.participant.identity) ?? -1;
            if(id == -1) return;

            // Subscribe if only one
            if(screenshares.isEmpty) {
              event.publication.subscribe();
            }

            screenshares[id] = Screenshare(Get.find<CallMemberController>().members[id]!, event.publication as RemoteTrackPublication<RemoteVideoTrack>);
          } else {
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

          // Unsubscribe from screenshare
          if(event.publication.isScreenShare) {
            event.publication.unsubscribe();
            screenshares.remove(int.tryParse(event.participant.identity) ?? -1);
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
}

class Screenshare {
  final Member member;
  final RemoteTrackPublication<RemoteVideoTrack> publication;
  final loading = true.obs;

  Screenshare(this.member, this.publication) {

    // Wait for track to be ready
    final timer = Timer.periodic(1000.ms, (timer) {
      if(publication.track != null) {
        loading.value = false;
        timer.cancel();
      }
    });
  }

}