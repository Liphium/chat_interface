import 'package:chat_interface/controller/chat/conversation/call/call_controller.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class PublicationController extends GetxController {

  // Output status
  final output = true.obs;
  final outputLoading = false.obs;

  void changeOutputDevice(MediaDevice device) async {
    await Get.find<CallController>().room.value.setAudioOutputDevice(device);
    Get.find<SettingController>().settings["audio.output"]!.setValue(device.label);
  }

  void subscribeToStreams(EventsListener<RoomEvent> listener) {

    // Listen for new audio tracks
    listener.on<TrackPublishedEvent>((event) {

      if(event.publication.kind == TrackType.AUDIO) {

        // Subscribe to track
        if(output.value) {
          event.publication.subscribe();
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