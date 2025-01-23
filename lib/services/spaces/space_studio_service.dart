import 'dart:async';

import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SpaceStudioService {
  /// Connect to Studio (Liphium's WebRTC SFU integrated into Spaces)
  ///
  /// Returns a new WebRTC connection and an error if there was one.
  static Future<(RTCPeerConnection?, String?)> connectToStudio() async {
    // Make sure we are connected to a Space
    if (!SpaceController.connected.peek() || SpaceConnection.spaceConnector == null) {
      return (null, "error.connection".tr);
    }

    // Get all the info needed for a WebRTC connection from the server
    final event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("sf_info", {}));
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

    // Wait for one candidate to be gathered and then generate an offer
    // TODO: Improve the handling of this in the future using trickle-ice
    final completer = Completer<bool>();
    peer.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        completer.complete(true);
      }
    };

    // Cancel the connection attempt in case it can't be completed quickly enough
    final success = await completer.future.timeout(
      Duration(seconds: 10),
      onTimeout: () => false,
    );
    if (!success) {
      return (null, "error.studio.rtc".trParams({"code": "1"}));
    }

    // Add all the required transceivers
    await peer.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeData,
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendRecv,
      ),
    );
    await peer.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendRecv,
      ),
    );
    await peer.addTransceiver(
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendRecv,
      ),
    );

    // Create an offer for the server
    final offer = await peer.createOffer({});

    return (null, null);
  }
}
