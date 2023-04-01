import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallController extends GetxController {

  final conversation = 0.obs;
  final livekit = false.obs;
  final connected = false.obs;
  final disconnecting = false.obs;
  final room = Room().obs;
  final friends = <Friend>[].obs;
  final participants = <int, Participant>{}.obs;

  late final EventsListener<RoomEvent> roomListener;

  // Open room without connection to Livekit (only for UI)
  void openWithoutLivekit(int conv) {
    conversation.value = conv;
    livekit.value = false;
  }

  void leaveCall() {
    conversation.value = 0;
    
    if(livekit.value) {
      room.value.disconnect();
    }
    livekit.value = false;
    participants.clear();
    friends.clear();
  }

  // Join room using Livekit (for connection)
  void joinWithLivekit(int conv, String token) async {
    conversation.value = conv;
    livekit.value = true;
    disconnecting.value = true;
    
    final options = RoomOptions(
      adaptiveStream: true,
      dynacast: true,

      //* Headphones
      defaultAudioOutputOptions: AudioOutputOptions(
        deviceId: Get.find<SettingController>().settings["audio.output"]!.getValue(),
      )
    );

    // Microphone track
    final microphone = await LocalAudioTrack.create(
      AudioCaptureOptions(
        deviceId: Get.find<SettingController>().settings["audio.microphone"]!.getValue(),
      )
    );

    // Join room
    await room.value.connect(liveKitURL, token,
      roomOptions: options,

      fastConnectOptions: FastConnectOptions(
        microphone: TrackOption(
          enabled: true,
          track: microphone,
        ),
      )
    );

    // Add all other friends
    for(var participant in room.value.participants.values) {
      final id = int.parse(participant.identity);
      final replacer = Friend(0, "fj-${participant.identity}", "key", "tag");

      friends.add(Get.find<FriendController>().friends[id] ?? replacer);
      participants[id] = participant;
    }

    //* Listen to room events
    roomListener = room.value.createListener();
  
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
        FriendController controller = Get.find();

        final id = int.parse(event.participant.identity);
        final replacer = Friend(0, "fj-${event.participant.identity}", "key", "tag");

        friends.add(controller.friends[id] ?? replacer);
        print("CONNECTED ${event.participant.identity}");
        participants[id] = event.participant;
      })

      //* Remove participant from list
      ..on<ParticipantDisconnectedEvent>((event) {
        friends.removeWhere((element) => element.id == int.parse(event.participant.identity));
        print("DISCONNECTED ${event.participant.identity}");
        participants.remove(int.parse(event.participant.identity));
      })

      ;

  }
}