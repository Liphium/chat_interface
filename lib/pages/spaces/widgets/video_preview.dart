import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:signals/signals_flutter.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({super.key});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> with SignalsMixin {
  final initialized = signal(false);
  MediaStream? _mediaStream;
  final renderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    await renderer.initialize();
    _mediaStream = await mediaDevices.getUserMedia(_getMediaConstraints(audio: false, video: true));
    if (_mediaStream!.getVideoTracks().isEmpty) {
      sendLog("warning: no video tracks");
      return;
    }

    // Start the tracks
    for (var track in _mediaStream!.getVideoTracks()) {
      track.enabled = true;
    }

    // Add it to the renderer
    renderer.srcObject = _mediaStream;
    initialized.value = true;
  }

  /// Media constraints for video and audio tracks
  Map<String, dynamic> _getMediaConstraints({bool audio = true, bool video = true}) {
    return {
      'audio': audio ? true : false,
      'video': video
          ? {
              'mandatory': {
                'minWidth': '1920',
                'minHeight': '1080',
                'width': '1920',
                'height': '1080',
                'minFrameRate': '24',
                'frameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };
  }

  @override
  void dispose() {
    _mediaStream!.getTracks().forEach(
      (element) {
        element.stop();
      },
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Watch((context) {
          if (!initialized.value) {
            return const SizedBox();
          }

          return RTCVideoView(renderer);
        }),
      ),
    );
  }
}
