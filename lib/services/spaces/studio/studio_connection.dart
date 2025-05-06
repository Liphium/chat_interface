import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/studio/studio_controller.dart';
import 'package:chat_interface/pages/settings/app/audio_settings.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/services/spaces/studio/studio_track_publisher.dart';
import 'package:chat_interface/src/rust/api/engine.dart' as libspace;
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioConnection {
  final RTCPeerConnection _peer;
  late final StudioTrackPublisher _publisher;
  libspace.LightwireEngine? _engine;
  Timer? _talkingTimer;
  final _disposeFunctions = <Function()>[];

  StudioConnection(this._peer) {
    // Create all the required listeners on the peer
    _peer
      ..onConnectionState = (state) {
        sendLog("studio: new connection state: $state");
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          StudioController.handleDisconnect();
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
      ..onTrack = _handleNewTrack;

    // Create the publisher to manage all the tracks
    _publisher = StudioTrackPublisher(this);
  }

  /// Create the default data channel used for lightwire
  Future<void> createLightwireChannel() async {
    // Create the channel
    final channel = await _peer.createDataChannel(
      "lightwire",
      RTCDataChannelInit()
        ..maxRetransmits = 0
        ..ordered = false,
    );

    // Create a new timer for making sure talking states are deleted once no longer talking
    _talkingTimer = Timer.periodic(100.ms, (timer) {
      final flagDate = DateTime.now().subtract(250.ms);
      for (var member in SpaceMemberController.members.peek().values) {
        if (member.id == SpaceMemberController.getOwnId()) {
          continue;
        }
        // Check if they have not talked since the last iteration
        member.talking.value = !(member.lastPacket?.isBefore(flagDate) ?? !member.talking.peek());
      }
    });

    // Subscribe to all the events the data channel has
    _handleLightwireChannel(channel);
  }

  /// Handle a new data channel created by the server or the client
  void _handleLightwireChannel(RTCDataChannel channel) {
    channel.bufferedAmountLowThreshold = 256 * 1024; // 256 KB

    // Subscribe to all the events the data channel has
    channel
      ..onDataChannelState = (state) async {
        sendLog("studio: state of lightwire: $state");

        // Start lightwire when the channel has been opeed
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          sendLog("studio: starting lightwire..");

          // Create a new lightwire engine and wire it up with the data channel
          _engine = await libspace.createLightwireEngine();
          libspace.startPacketStream(engine: _engine!).listen((data) {
            final (packet, amplitude, speech) = data;
            SpaceMemberController.handleTalkingState(SpaceMemberController.getOwnId(), speech ?? false);

            // Send the packets to the data channel
            if (packet != null) {
              channel.send(RTCDataChannelMessage.fromBinary(packet));
            }
          });

          // Listen for output and input device changes to make sure the current engine is also using them
          _disposeFunctions.add(
            AudioSettings.microphone.value.subscribe((value) {
              if (_engine != null) {
                libspace.setInputDevice(engine: _engine!, device: value ?? AudioSettings.useDefaultDevice);
              }
            }),
          );
          _disposeFunctions.add(
            AudioSettings.outputDevice.value.subscribe((value) {
              if (_engine != null) {
                libspace.setOutputDevice(engine: _engine!, device: value ?? AudioSettings.useDefaultDevice);
              }
            }),
          );
          _disposeFunctions.addAll(await AudioSettings.subscribeToSettings(_engine!));
        }

        // Close the lightwire engine when the data channel is closed
        if (state == RTCDataChannelState.RTCDataChannelClosed && _engine != null) {
          await libspace.stopEngine(engine: _engine!);
          SpaceMemberController.handleTalkingState(SpaceMemberController.getOwnId(), false);
        }
      }
      ..onMessage = (msg) {
        if (!msg.isBinary) {
          sendLog("studio: error: message other than binary over lightwire");
          return;
        }

        // Decode the packet
        // Format: | id_length (8 bytes) | client_id (of id_length) | voice_data (rest) |
        final bytes = msg.binary;
        final idLength = bytes[0];
        final clientIdBytes = bytes.sublist(1, 1 + idLength);
        final clientId = utf8.decode(clientIdBytes);
        final voicePacket = bytes.sublist(1 + idLength);

        // Set talking state (will be automatically cleared)
        final member = SpaceMemberController.getMember(clientId);
        member?.talking.value = true;
        member?.lastPacket = DateTime.now();

        // Let lightwire handle the rest
        unawaited(libspace.handlePacket(engine: _engine!, id: clientId, packet: voicePacket));
      }
      ..onBufferedAmountLow = (buf) {
        sendLog("studio: lightwire buffer amount low");
      };
  }

  /// Handle a new ice candidate
  void handleIceCandidate(RTCIceCandidate candidate) {
    _peer.addCandidate(candidate);
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
      // TODO: Re-enable when video is implemented
      /* "offerToReceiveVideo": true, */
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

  /// Handle the update of the audio state
  Future<void> handleAudioState({bool? muted, bool? deafened}) async {
    if (muted != null) {
      await libspace.setVoiceEnabled(engine: _engine!, enabled: !muted);
    }
    if (deafened != null) {
      await libspace.setAudioEnabled(engine: _engine!, enabled: !deafened);
    }
  }

  /// Get the underlying RTC connection
  RTCPeerConnection getPeer() {
    return _peer;
  }

  /// Get the underlying Track publisher
  StudioTrackPublisher getPublisher() {
    return _publisher;
  }

  libspace.LightwireEngine? getEngine() {
    return _engine;
  }

  void close() {
    _talkingTimer?.cancel();
    _peer.close(); // This will close lightwire, etc.
    for (var func in _disposeFunctions) {
      func.call();
    }
  }
}
