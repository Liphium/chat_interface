import 'package:chat_interface/controller/chat/conversation/call/call_member_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/microphone_controller.dart';
import 'package:chat_interface/controller/chat/conversation/call/output_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallController extends GetxController {

  //* Call status
  final conversation = 0.obs;
  final livekit = false.obs;
  final connected = false.obs;
  final disconnecting = false.obs;

  //* Call layout
  final expanded = false.obs;
  final showMembers = false.obs;
  final hideOverlay = false.obs;

  //* Call data
  final room = Room().obs;

  late EventsListener<RoomEvent> roomListener;

  // Open room without connection to Livekit (only for UI)
  void openWithoutLivekit(int conv) {
    conversation.value = conv;
    livekit.value = false;
  }

  void leaveCall() {
    conversation.value = 0;
    
    // Tell other controllers about it
    Get.find<CallMemberController>().onDisconnect();
    Get.find<MicrophoneController>().endCall();

    if(livekit.value) {
      room.value.disconnect();
    }
    livekit.value = false;
    roomListener.cancelAll();
  }

  // Join room using Livekit (for connection)
  void joinWithLivekit(int conv, String token) async {
    conversation.value = conv;
    disconnecting.value = false;
    
    // Join room
    String output = Get.find<SettingController>().settings["audio.output"]!.getOr("def");
    final options = RoomOptions(
      adaptiveStream: true,
      dynacast: true,

      //* Default output
      defaultAudioOutputOptions: AudioOutputOptions(
        deviceId: output == "def" ? null : output,
      ),
      
      //* Setting default audio bitrate
      defaultAudioPublishOptions: const AudioPublishOptions(
        dtx: true,
        audioBitrate: AudioPreset.musicHighQualityStereo,
      )
    );

    await room.value.connect(liveKitURL, token,
      roomOptions: options,
    );

    // Init other call related controllers
    Get.find<CallMemberController>().onCall(room.value);
    Get.find<MicrophoneController>().setupTracks(this);

    //* Listen to room events
    roomListener = room.value.createListener();

    // Init listeners on other controllers
    Get.find<PublicationController>().subscribeToStreams(roomListener);
  
    roomListener
      
      //* Room disconnected
      ..on<RoomDisconnectedEvent>((_) {
        if(disconnecting.value) {
          return;
        }

        connected.value = false;
        showMessage(SnackbarType.error, "You have been disconnected from the call. Trying to reconnect..");
      })

      //* Room reconnected
      ..on<RoomReconnectedEvent>((e) {
        connected.value = true;
      })

      //* Add participant to list
      ..on<ParticipantConnectedEvent>((event) {
        CallMemberController controller = Get.find();
        controller.addMember(event.participant);
      })

      //* Remove participant from list
      ..on<ParticipantDisconnectedEvent>((event) {
        CallMemberController controller = Get.find();
        controller.disconnectMember(event.participant);
      })

      ;

    // Show the call in the UI
    livekit.value = true;
  }
}