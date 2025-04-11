import 'dart:async';

import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_track_controller.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/services/spaces/studio/studio_connection.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioService {
  /// Connect to Studio (Liphium's WebRTC SFU integrated into Spaces)
  ///
  /// Returns a new WebRTC connection and an error if there was one.
  static Future<(StudioConnection?, String?)> connectToStudio() async {
    // Make sure we are connected to a Space
    if (!SpaceController.connected.peek() || SpaceConnection.spaceConnector == null) {
      return (null, "error.connection".tr);
    }

    // Get all the info needed for a WebRTC connection from the server
    var event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("st_info", {}));
    if (event == null) {
      return (null, "server.error".tr);
    }
    if (!event.data["success"]) {
      return (null, event.data["message"] as String);
    }

    // Create a connection and generate an offer
    final peer = await createPeerConnection({
      "iceServers": [
        {
          "urls": ["stun:${event.data["stun"]}"],
        },
      ],
    });

    // Create a data channel for pipes
    final studioConn = StudioConnection(peer);
    await studioConn.createLightwireChannel();

    // Create an offer for the server
    final offer = await peer.createOffer({
      // TODO: Uncomment when video implementation is done
      // "offerToReceiveVideo": true,
    });
    await peer.setLocalDescription(offer);

    // Send all the ice candidates to the server
    final completer = Completer<void>();
    peer.onIceCandidate = (candidate) async {
      if (candidate.candidate != null) {
        await completer.future; // Make sure to not send ice candidates before the client is registered
        SpaceConnection.spaceConnector!.sendAction(ServerAction("st_ice", candidate.toMap()));
      }
    };

    // Send the offer to the server
    event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("st_join", offer.toMap()));
    if (event == null) {
      return (null, "error.studio.rtp".trParams({"code": "200"}));
    }
    if (!event.data["success"]) {
      return (null, event.data["message"] as String);
    }
    completer.complete();

    // Accept the offer from the server
    await peer.setRemoteDescription(RTCSessionDescription(event.data["answer"]["sdp"], event.data["answer"]["type"]));

    return (studioConn, null);
  }

  /// Register all event handlers needed for Studio.
  static void setupStudioHandlers(Connector connector) {
    // Handle track updates
    connector.listen("st_tr_update", (event) {
      // Convert to a track
      final track = StudioTrack(
        id: event.data["track"],
        publisher: SpaceMemberController.members[event.data["sender"]]!,
        paused: event.data["paused"],
        channels: List<String>.generate(event.data["channels"].length, (index) {
          return event.data["channels"][index] as String;
        }),
        subscribers: event.data["subs"] ?? [],
      );

      // Tell the controller about the updated track
      StudioTrackController.updateOrRegisterTrack(track);
    });

    // Handle track deletion
    connector.listen("st_tr_deleted", (event) {
      // Tell the controller about the deleted track
      StudioTrackController.deleteTrack(event.data["track"]);
    });

    // Handle ice candidates for studio
    connector.listen("st_ice", (event) {
      // Pass the candidate to the current connection
      final candidate = event.data["candidate"];
      StudioController.getConnection()?.handleIceCandidate(RTCIceCandidate(candidate["candidate"], candidate["sdpMid"], candidate["sdpMLineIndex"]));
    });
  }

  /// Update your audio state on the server. Set muted and deafened only when changed.
  ///
  /// Returns an error if there was one.
  static Future<String?> updateAudioState({bool? muted, bool? deafened}) async {
    assert(muted != null || deafened != null);

    // Send the new audio state to the server
    final event = await SpaceConnection.spaceConnector!.sendActionAndWait(
      ServerAction("set_audio_state", {if (muted != null) "muted": muted, if (deafened != null) "deafened": deafened}),
    );
    if (event == null) {
      return "server.error".tr;
    }
    if (!event.data["success"]) {
      return event.data["message"];
    }

    // Update the audio state on the underlying connection
    unawaited(StudioController.getConnection()?.handleAudioState(muted: muted, deafened: deafened));

    return null;
  }
}
