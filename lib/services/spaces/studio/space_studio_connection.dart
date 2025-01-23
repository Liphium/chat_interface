import 'dart:async';

import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioConnection {
  final RTCPeerConnection _peer;

  StudioConnection(this._peer) {
    // Create all the required listeners on the peer
    _peer
      ..onConnectionState = (state) {
        sendLog("studio: new connection state: $state");
      }
      ..onRenegotiationNeeded = () {
        sendLog("renegotiation needed, not sure what do here yet");
      }
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
  }

  /// Handle a new data channel created by the server
  void _handleDataChannel(RTCDataChannel channel) {
    // Start a timer to send messages since there is currently only the keepalive channel
    final timer = Timer.periodic(
      Duration(seconds: 2),
      (timer) {
        channel.send(RTCDataChannelMessage("liphium_v$protocolVersion"));
      },
    );

    // Subscribe to all the events the data channel has
    channel
      ..onDataChannelState = (state) {
        sendLog("studio: state of ${channel.label ?? "no_label_dc"}: $state");

        // Cancel the timer sending keep alive in case closed
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          timer.cancel();
        }
      }
      ..onMessage = (msg) {
        sendLog("studio: received ${msg.text} from server");
      };
  }

  /// Handle a new track
  void _handleNewTrack(RTCTrackEvent event) {
    sendLog("studio: received new track: ${event.track.kind ?? "no type found"}");
  }
}
