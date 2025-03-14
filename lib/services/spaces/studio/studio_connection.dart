import 'dart:async';

import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_track_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/services/spaces/studio/studio_track_publisher.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioConnection {
  final RTCPeerConnection _peer;
  late final StudioTrackPublisher _publisher;

  StudioConnection(this._peer) {
    // Create all the required listeners on the peer
    _peer
      ..onConnectionState = (state) {
        sendLog("studio: new connection state: $state");
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          StudioController.handleDisconnect();
          StudioTrackController.handleDisconnect();
        }
      }
      ..onRenegotiationNeeded = _handleRenegotiation
      ..onSignalingState = (state) {
        sendLog("studio: new signaling state: $state");
      }
      ..onIceConnectionState = (state) {
        sendLog("studio: new ice connection state: $state");
      }
      ..onIceGatheringState = (state) {
        sendLog("studio: new ice gathering state: $state");
      }
      ..onDataChannel = _handleDataChannel
      ..onTrack = _handleNewTrack;

    // Create the publisher to manage all the tracks
    _publisher = StudioTrackPublisher(this);
  }

  /// Create the default data channel used for pipes (but for now only keepalive packets)
  Future<void> createPipesChannel() async {
    // Create the channel
    final channel = await _peer.createDataChannel(
      "pipes",
      RTCDataChannelInit()
        ..maxRetransmitTime = 500
        ..ordered = false,
    );

    // Start a timer to send messages over this channel (just for keeping the connection)
    final timer = Timer.periodic(
      Duration(seconds: 2),
      (timer) {
        channel.send(RTCDataChannelMessage("liphium_v$protocolVersion"));
      },
    );

    // Subscribe to all the events the data channel has
    _handleDataChannel(channel, timer: timer);
  }

  /// Handle a new data channel created by the server
  void _handleDataChannel(RTCDataChannel channel, {Timer? timer}) {
    if (timer == null) {
      sendLog("server registered new data channel: ${channel.label!}");
    }

    // Subscribe to all the events the data channel has
    channel
      ..onDataChannelState = (state) {
        sendLog("studio: state of ${channel.label ?? "no_label_dc"}: $state");

        // Cancel the timer sending keep alive in case closed
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          timer?.cancel();
        }
      }
      ..onMessage = (msg) {
        sendLog("studio: received ${msg.text} from server");
      };
  }

  /// Handle the renegotiation
  ///
  /// TODO: This should be the way we always negotiate with the server
  Future<void> _handleRenegotiation() async {
    if ((_peer.connectionState ?? RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) !=
        RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      return;
    }
    sendLog("studio: renegotiating with the server..");

    // Create a new offer
    final offer = await _peer.createOffer({
      "offerToReceiveAudio": true,
      "offerToReceiveVideo": true,
    });
    await _peer.setLocalDescription(offer);

    // Send the server the new offer
    final event = await SpaceConnection.spaceConnector!.sendActionAndWait(ServerAction("st_reneg", offer.toMap()));
    if (event == null) {
      sendLog("studio: renegotiation failed, disconnect would be good probably");
      return;
    }
    if (!event.data["success"]) {
      sendLog("studio: renegotiation failed cause of ${event.data["message"]}, disconnect would be good probably");
      return;
    }

    // Set new answer as remote description
    await _peer.setRemoteDescription(RTCSessionDescription(event.data["answer"]["sdp"], event.data["answer"]["type"]));
  }

  /// Handle a new track
  void _handleNewTrack(RTCTrackEvent event) {
    sendLog("studio: received new track: ${event.track.kind ?? "no type found"}");
  }

  /// Get the underlying RTC connection
  RTCPeerConnection getPeer() {
    return _peer;
  }

  /// Get the underlying Track publisher
  StudioTrackPublisher getPublisher() {
    return _publisher;
  }
}
