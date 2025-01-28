import 'dart:async';

import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_track_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioConnection {
  final RTCPeerConnection _peer;

  // Tracks the connection is publishing
  MediaStream? _localStream;

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

  /// Handle a new track
  void _handleNewTrack(RTCTrackEvent event) {
    sendLog("studio: received new track: ${event.track.kind ?? "no type found"}");
  }

  // Create a new video track
  void createVideoTrack() async {
    final media = await mediaDevices.getUserMedia(_getMediaConstraints(audio: false));
    if (_localStream != null) {
      // Remove all the existing video tracks
      for (var track in _localStream!.getVideoTracks()) {
        try {
          await _localStream!.removeTrack(track);
        } catch (e) {
          sendLog("error: couldn't stop local track: $e");
        }
        await track.stop();
      }

      // Add all the new tracks
      for (var track in media.getVideoTracks()) {
        await _localStream!.addTrack(track);
      }
    } else {
      _localStream = media;
    }
  }

  /// Media constraints for video and audio tracks
  Map<String, dynamic> _getMediaConstraints({bool audio = true, bool video = true}) {
    return {
      'audio': audio ? true : false,
      'video': video
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };
  }
}
