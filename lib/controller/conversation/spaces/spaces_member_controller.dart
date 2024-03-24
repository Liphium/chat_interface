import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
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
              final controller = Get.find<SettingController>();
              await participant.setMicrophoneEnabled(
                true,
                audioCaptureOptions: AudioCaptureOptions(
                  echoCancellation: controller.settings[AudioSettings.echoCancellation]!.getValue(),
                  autoGainControl: controller.settings[AudioSettings.autoGainControl]!.getValue(),
                  noiseSuppression: controller.settings[AudioSettings.noiseSuppression]!.getValue(),
                  highPassFilter: controller.settings[AudioSettings.highPassFilter]!.getValue(),
                  typingNoiseDetection: controller.settings[AudioSettings.typingNoiseDetection]!.getValue(),
                ),
              );
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
        sendLog("participant connected");
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
  final isVideo = false.obs;
  final isScreenshare = false.obs;

  SpaceMember(this.friend, this.id, bool muted, bool deafened) {
    isMuted.value = muted;
    isDeafened.value = deafened;
  }

  void joinVoice(Participant participant) {
    this.participant.value = participant;

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
        _disableVideo(event.publication);
      })
      ..on<TrackUnmutedEvent>((event) async {
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
    }
  }

  void _enableVideo(TrackPublication pub) {
    if (pub.kind == TrackType.VIDEO) {
      if (pub.isScreenShare) {
        isScreenshare.value = true;
      } else {
        isVideo.value = true;
      }
    }
  }

  void leaveVoice() {
    participant.value?.dispose();
    participant.value = null;
  }
}
