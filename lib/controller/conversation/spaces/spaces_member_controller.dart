import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceMemberController extends GetxController {
  SecureKey? key;
  final membersLoading = false.obs;
  final members = <String, SpaceMember>{}.obs;
  StreamSubscription<api.Action>? sub;
  static String ownId = "";

  // Action names
  static const String startedTalkingAction = "started_talking";
  static const String stoppedTalkingAction = "stopped_talking";

  void onMembersChanged(List<dynamic> members) {
    sendLog("members changed");
    final statusController = Get.find<StatusController>();
    final myId = statusController.id.value;
    final membersFound = <String>[];

    // id = encryptedId:clientId
    // muted = bool
    // deafened = bool
    for (var member in members) {
      final args = member["id"].split(":");
      final decrypted = decryptSymmetric(args[0], key!);
      final clientId = args[1];
      sendLog("$decrypted:$clientId");
      if (decrypted == myId) {
        SpaceMemberController.ownId = clientId;
      }
      membersFound.add(clientId);
      if (this.members[clientId] == null) {
        this.members[clientId] = SpaceMember(Get.find<FriendController>().friends[decrypted] ?? (decrypted == myId ? Friend.me(statusController) : Friend.unknown(decrypted)),
            clientId, member["muted"], member["deafened"]);
      }
    }

    // Remove everyone who left the space
    this.members.removeWhere((key, value) => !membersFound.contains(key));
    membersLoading.value = false;
  }

  void onConnect(SecureKey key) async {
    this.key = key;

    sub = api.createActionStream().listen((event) async {
      if (members[ownId] == null) {
        return;
      }
      switch (event.action) {
        // Talking stuff
        case startedTalkingAction:
          if (members[ownId]!.isMuted.value || members[ownId]!.isDeafened.value) {
            return;
          }
          if (members[ownId]!.participant.value != null) {
            final participant = members[ownId]!.participant.value! as LocalParticipant;
            if (participant.audioTrackPublications.isEmpty) {
              await participant.setMicrophoneEnabled(true);
            } else if (participant.audioTrackPublications.isNotEmpty) {
              await participant.audioTrackPublications.first.unmute();
            }
          }
          members[ownId]!.isSpeaking.value = true;

        case stoppedTalkingAction:
          if (members[ownId]!.participant.value != null) {
            final participant = members[ownId]!.participant.value! as LocalParticipant;
            if (participant.audioTrackPublications.isNotEmpty) {
              await participant.audioTrackPublications.first.mute();
            }
          }
          members[ownId]!.isSpeaking.value = false;
      }
    });
  }

  void onLivekitConnected() {
    SpacesController.livekitRoom!.createListener()
      ..on<ParticipantConnectedEvent>((event) {
        if (event.participant.identity == StatusController.ownAccountId) {
          return;
        }
        members[event.participant.identity]?.joinVoice(event.participant);
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        if (event.participant.identity == StatusController.ownAccountId) {
          return;
        }
        members[event.participant.identity]?.leaveVoice();
      });
    members[ownId]!.joinVoice(SpacesController.livekitRoom!.localParticipant!);

    for (var remote in SpacesController.livekitRoom!.remoteParticipants.values) {
      for (var track in remote.audioTrackPublications) {
        if (track.kind != TrackType.AUDIO) continue;
        track.subscribe();
      }
    }
  }

  void onDisconnect() {
    membersLoading.value = true;
    members.clear();
    sub!.cancel();
  }

  bool isLocalDeafened() {
    return members[ownId]!.isDeafened.value;
  }
}

class SpaceMember {
  final String id;
  final Friend friend;
  final participant = Rx<Participant?>(null);

  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isDeafened = false.obs;

  SpaceMember(this.friend, this.id, bool muted, bool deafened) {
    isMuted.value = muted;
    isDeafened.value = deafened;
  }

  void joinVoice(Participant participant) {
    this.participant.value = participant;

    if (participant is RemoteParticipant) {
      if (Get.find<SpaceMemberController>().isLocalDeafened()) {
        return;
      }
      for (var track in participant.audioTrackPublications) {
        if (track.kind == TrackType.AUDIO) {
          track.subscribe();
        }
      }
    }

    participant.createListener()
      ..on<TrackPublishedEvent>((event) {
        sendLog("track published");
        if (event.publication.kind == TrackType.AUDIO && !Get.find<SpaceMemberController>().isLocalDeafened()) {
          event.publication.subscribe();
        }
      })
      ..on<TrackUnpublishedEvent>((event) {
        sendLog("track unpublished");
        // TODO: Handle something here
      });
  }

  void leaveVoice() {
    participant.value?.dispose();
    participant.value = null;
  }
}
