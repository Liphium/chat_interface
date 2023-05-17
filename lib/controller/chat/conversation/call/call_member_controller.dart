import 'package:chat_interface/controller/chat/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class CallMemberController extends GetxController {

  final members = <String, Member>{}.obs;

  void onCall(Room room) {

    // Add all members
    for(var participant in room.participants.entries) {
      addMember(participant.value);
    }

    addMember(room.localParticipant!);
  }

  void onDisconnect() {

    // Remove all listeners
    for(var member in members.values) {
      member.disconnect();
    }

    // Remove all members
    members.clear();
  }

  void addMember(Participant participant) {

    // Check for local participant
    if(participant is LocalParticipant) {

      StatusController controller = Get.find();
      members[controller.id.value] = Member(Friend(controller.id.value, controller.name.value, "key", controller.tag.value), participant);

      return;
    }

    // Check for self (sometimes happens when timing out)
    if(participant.identity == "${Get.find<StatusController>().id.value}") {
      return;
    }

    final replacer = Friend("0", "fj-${participant.identity}", "key", "tag");
    final friend = Get.find<FriendController>().friends[int.parse(participant.identity)] ?? replacer;

    members[friend.id] = Member(friend, participant);
  }

  void disconnectMember(Participant participant) {
    final member = members[int.parse(participant.identity)];
    if(member == null) {
      return;
    }
    member.disconnect();
    members.remove(member.friend.id);
  }

}

class Member {

  final Friend friend;
  final Participant participant;
  
  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isAudioMuted = false.obs;

  late EventsListener<ParticipantEvent> listener;

  Member(this.friend, this.participant) {

    isSpeaking.value = !participant.isMuted;
    isMuted.value = false;
    
    // Subscribe to participant changes
    participant.addListener(_onChanged);
  }

  void _onChanged() {
    isSpeaking.value = !participant.isMuted;
    isMuted.value = false;
  }

  void disconnect() {
    participant.removeListener(_onChanged);
  }

}