import 'dart:async';

import 'package:chat_interface/controller/spaces/space_controller.dart';
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
          "urls": [
            "stun:${event.data["stun"]}",
          ]
        }
      ],
    });

    // Create a data channel for pipes
    final studioConn = StudioConnection(peer);
    await studioConn.createPipesChannel();

    // Create an offer for the server
    final offer = await peer.createOffer({
      "offerToReceiveAudio": true,
      "offerToReceiveVideo": true,
    });
    await peer.setLocalDescription(offer);

    // Wait for one candidate to be gathered and then generate an offer
    // TODO: Improve the handling of this in the future using trickle-ice
    final completer = Completer<bool>();
    peer.onIceCandidate = (candidate) {
      if (candidate.candidate != null && !completer.isCompleted) {
        completer.complete(true);
      }
    };

    // Cancel the connection attempt in case it can't be completed quickly enough
    final success = await completer.future.timeout(
      Duration(seconds: 10),
      onTimeout: () => false,
    );
    if (!success) {
      return (null, "error.studio.rtc".trParams({"code": "100"}));
    }

    // Send the offer to the server
    event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("st_join", offer.toMap()));
    if (event == null) {
      return (null, "error.studio.rtp".trParams({"code": "200"}));
    }
    if (!event.data["success"]) {
      return (null, event.data["message"] as String);
    }

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
        publisher: event.data["sender"],
        paused: event.data["paused"],
        channels: event.data["channels"],
        subscribers: event.data["subs"],
      );

      // Tell the controller about the updated track
      StudioTrackController.updateOrRegisterTrack(track);
    });

    // Handle track deletion
    connector.listen("st_tr_deleted", (event) {
      // Tell the controller about the deleted track
      StudioTrackController.deleteTrack(event.data["track"]);
    });
  }
}
