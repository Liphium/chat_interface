import 'package:chat_interface/services/spaces/studio/media_profile.dart';
import 'package:chat_interface/services/spaces/studio/studio_connection.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioTrackPublisher {
  /// The connection this track publisher is related to
  final StudioConnection _connection;

  final List<RTCRtpTransceiver> transceivers = [];

  StudioTrackPublisher(this._connection);

  /// The local stream that has all the tracks inside of it
  MediaStream? _stream;

  /// Create a video track for the camera
  Future<void> createCameraTrack() async {
    // Determine a good quality for the camera
    final bandwidth = await determineBandwidth();
    final profile = MediaProfiles.determineMediaProfile(MediaProfileType.balanced, bandwidth);

    sendLog("using profile $profile");

    // Get the actual user's stream
    final media = await mediaDevices.getUserMedia(_getMediaConstraints(video: profile));
    if (_stream != null) {
      // Remove all the existing video tracks
      for (var track in _stream!.getVideoTracks()) {
        try {
          await _stream!.removeTrack(track);
        } catch (e) {
          sendLog("error: couldn't stop local track: $e");
        }
        await track.stop();
      }

      // Add all the new tracks
      for (var track in media.getVideoTracks()) {
        await _stream!.addTrack(track);
      }
    } else {
      _stream = media;
    }

    // Make sure there are tracks to publish
    if (media.getVideoTracks().isEmpty) {
      sendLog("error: no video tracks found");
      return;
    }

    // Add the video track
    final videoTrack = media.getVideoTracks()[0];
    final encodings = [
      RTCRtpEncoding(active: true, rid: "f", maxBitrate: profile.bitrate, scaleResolutionDownBy: 1),
      RTCRtpEncoding(
        active: false,
        rid: "h",
        maxBitrate: (profile.bitrate / 2).toInt(),
        scaleResolutionDownBy: 2,
      ),
      RTCRtpEncoding(
        active: false,
        rid: "q",
        maxBitrate: (profile.bitrate / 4).toInt(),
        scaleResolutionDownBy: 4,
      ),
    ];

    // Create the transceiver for simulcasting
    final transceiver = await _connection.getPeer().addTransceiver(
      track: videoTrack,
      kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      init: RTCRtpTransceiverInit(
        direction: TransceiverDirection.SendOnly,
        streams: [media],
        sendEncodings: encodings,
      ),
    );
    transceivers.add(transceiver);
  }

  /// Media constraints for video and audio tracks
  Map<String, dynamic> _getMediaConstraints({bool audio = false, MediaProfile? video}) {
    return {
      'audio': audio ? true : false,
      'video': video != null ? {'mandatory': video.toConstraints(), 'facingMode': 'user'} : false,
    };
  }

  /// Determine the available bandwidth of the user by getting the stats of the connection
  Future<double?> determineBandwidth() async {
    // Try to read it from the stats
    final stats = await _connection.getPeer().getStats();
    for (var stat in stats) {
      if (stat.type == "candidate-pair") {
        if (stat.values.containsKey("availableOutgoingBitrate")) {
          return stat.values["availableOutgoingBitrate"];
        }
      }
    }

    // Return null if non existent
    return null;
  }
}
