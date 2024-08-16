import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/publication_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
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
    final myId = StatusController.ownAccountId;
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
        this.members[clientId] = SpaceMember(
            Get.find<FriendController>().friends[decrypted] ?? (decrypted == myId ? Friend.me(statusController) : Friend.unknown(decrypted)), clientId, member["muted"], member["deafened"]);

        // See if there is already a participant with that id in the call
        if (SpacesController.livekitRoom != null) {
          for (var participant in SpacesController.livekitRoom!.remoteParticipants.values) {
            if (participant.identity == clientId) {
              this.members[clientId]!.joinVoice(participant);
              break;
            }
          }
        }
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
        sendLog("own member not there");
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
              sendLog("starting track");
              final controller = Get.find<SettingController>();
              final selected = controller.settings[AudioSettings.microphone]!.getOr("def");
              final device = await Get.find<PublicationController>().getMicrophone(selected);
              final track = await participant.setMicrophoneEnabled(
                true,
                audioCaptureOptions: AudioCaptureOptions(
                  deviceId: device,
                  echoCancellation: controller.settings[AudioSettings.echoCancellation]!.getValue(),
                  autoGainControl: controller.settings[AudioSettings.autoGainControl]!.getValue(),
                  noiseSuppression: controller.settings[AudioSettings.noiseSuppression]!.getValue(),
                  highPassFilter: controller.settings[AudioSettings.highPassFilter]!.getValue(),
                  typingNoiseDetection: controller.settings[AudioSettings.typingNoiseDetection]!.getValue(),
                  stopAudioCaptureOnMute: false,
                ),
              );
              if (track == null) {
                sendLog("failed to create");
              }
            } else if (participant.audioTrackPublications.isNotEmpty) {
              sendLog("unmuting track");
              await participant.audioTrackPublications.first.unmute();
            }
          }
          members[ownId]!.isSpeaking.value = true;

        case stoppedTalkingAction:
          if (members[ownId]!.participant.value != null) {
            final participant = members[ownId]!.participant.value! as LocalParticipant;
            if (participant.audioTrackPublications.isNotEmpty) {
              sendLog("muting track");
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
        sendLog("participant connected");
        if (members[event.participant.identity] != null) {
          sendLog("participant not found ${event.participant.identity}");
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
      assert(members[remote.identity] != null);
      members[remote.identity]?.joinVoice(remote);
      for (var pub in remote.trackPublications.values) {
        if (!pub.isScreenShare) {
          pub.subscribe();
        }
      }
    }
  }

  void onDisconnect() {
    membersLoading.value = true;
    members.clear();
    if (!configDisableRust) {
      sub!.cancel();
    }
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
  final isVideo = false.obs;
  final isScreenshare = false.obs;

  SpaceMember(this.friend, this.id, bool muted, bool deafened) {
    isMuted.value = muted;
    isDeafened.value = deafened;
  }

  void joinVoice(Participant participant) {
    this.participant.value = participant;
    sendLog("participant #${participant.identity} detected");

    participant.createListener()
      ..on<TrackPublishedEvent>((event) async {
        sendLog("track published");
        if (!event.publication.isScreenShare && !Get.find<SpaceMemberController>().isLocalDeafened()) {
          await event.publication.subscribe();
        }
      })
      ..on<TrackUnpublishedEvent>((event) async {
        _disableVideo(event.publication);
      })
      ..on<TrackMutedEvent>((event) async {
        if (event.publication.kind == TrackType.AUDIO) {
          isSpeaking.value = false;
        }
        _disableVideo(event.publication);
      })
      ..on<TrackUnmutedEvent>((event) async {
        if (event.publication.kind == TrackType.AUDIO) {
          isSpeaking.value = true;
        }
        _enableVideo(event.publication);
      })
      ..on<TrackUnsubscribedEvent>((event) async {
        _disableVideo(event.publication);
      })
      ..on<TrackSubscribedEvent>((event) async {
        _enableVideo(event.publication);
      });

    if (participant is RemoteParticipant) {
      if (Get.find<SpaceMemberController>().isLocalDeafened()) {
        return;
      }
      for (var pub in participant.trackPublications.values) {
        if (!pub.isScreenShare) {
          sendLog("subbing to audio");
          pub.subscribe();
        }
      }
    }
  }

  void _disableVideo(TrackPublication pub) {
    if (pub.kind == TrackType.VIDEO) {
      if (pub.isScreenShare) {
        isScreenshare.value = false;
      } else {
        isVideo.value = false;
      }
      sendLog("disabled video for ${friend.name}");
      Get.find<SpacesController>().updateRoomVideoState();
    }
  }

  void _enableVideo(TrackPublication pub) {
    if (pub.kind == TrackType.VIDEO) {
      if (pub.isScreenShare) {
        isScreenshare.value = true;
      } else {
        isVideo.value = true;
      }
      sendLog("enabled video for ${friend.name}");
      Get.find<SpacesController>().updateRoomVideoState();
    }
  }

  void leaveVoice() {
    participant.value?.dispose();
    participant.value = null;
  }
}
