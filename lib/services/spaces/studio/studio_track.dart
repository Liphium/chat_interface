import 'package:flutter_webrtc/flutter_webrtc.dart';

class PublishedStudioTrack {
  /// The transceiver responsible for the track
  final RTCRtpTransceiver _transceiver;

  /// The underlying media stream powering the track
  final MediaStream _stream;

  PublishedStudioTrack(this._transceiver, this._stream);
}
