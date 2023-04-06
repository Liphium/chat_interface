import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallMemberController extends GetxController {

  final members = <Member>[].obs;

  void onCall(Room room) {

    // Add all members
    for(var participant in room.participants.entries) {
      addMember(participant.value);
    }

    addMember(room.localParticipant!);
  }

  void onDisconnect() {

    // Remove all listeners
    for(var member in members) {
      member.disconnect();
    }

    // Remove all members
    members.clear();
  }

  void addMember(Participant participant) {

    // Check for local participant
    if(participant is LocalParticipant) {

      StatusController controller = Get.find();
      members.add(Member(Friend(controller.id.value, controller.name.value, "key", controller.tag.value), participant));

      return;
    }

    final replacer = Friend(0, "fj-${participant.identity}", "key", "tag");
    final friend = Get.find<FriendController>().friends[int.parse(participant.identity)] ?? replacer;

    members.add(Member(friend, participant));
  }

  void disconnectMember(Participant participant) {
    final member = members.firstWhere((element) => element.participant.sid == participant.sid);
    member.disconnect();
    members.remove(member);
  }

}

class Member {

  final Friend friend;
  final Participant participant;
  
  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final hearsAudio = false.obs;

  late EventsListener<ParticipantEvent> listener;

  Member(this.friend, this.participant) {

    isSpeaking.value = participant.isSpeaking;
    isMuted.value = participant.isMuted;
    
    // Subscribe to participant changes
    listener = participant.createListener();

    // Listen to events
    listener
      ..on<SpeakingChangedEvent>((event) {
        isSpeaking.value = event.speaking;
      })

      // Listen to mute changes
      ..on<TrackMutedEvent>((event) {
        if(event.publication.kind == TrackType.AUDIO) {
          isMuted.value = true;
        }
      })

      ..on<TrackUnmutedEvent>((event) {
        if(event.publication.kind == TrackType.AUDIO) {
          isMuted.value = false;
        }
      })
      
      // Listen to track changes
      ..on<TrackSubscribedEvent>((event) {
        if(event.publication.kind == TrackType.AUDIO) {
          hearsAudio.value = true;
        }
      })
      
      ..on<TrackUnsubscribedEvent>((event) {
        if(event.publication.kind == TrackType.AUDIO) {
          hearsAudio.value = false;
        }
      })
      
      ;
  }

  void disconnect() => listener.cancelAll();

}