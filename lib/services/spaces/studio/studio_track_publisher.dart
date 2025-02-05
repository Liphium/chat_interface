import 'package:chat_interface/services/spaces/studio/studio_connection.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class StudioTrackPublisher {
  /// The connection this track publisher is related to
  final StudioConnection _connection;

  StudioTrackPublisher(this._connection);

  /// The local stream that has all the tracks inside of it
  MediaStream? _stream;

  /// Create a video track for the camera
  Future<void> createCameraTrack() async {
    final media = await mediaDevices.getUserMedia(_getMediaConstraints(audio: false));
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

    // Create the transceiver
    final track = media.getVideoTracks()[0];
    await _connection.getPeer().addTransceiver(
          track: track,
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly,
            sendEncodings: [
              RTCRtpEncoding(
                rid: "d",
                active: true,
              ),
            ],
          ),
        );

    // Add the track to the connection
    await _connection.getPeer().addTrack(track);

    // Start all the tracks
    sendLog(media.getVideoTracks().length);
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
