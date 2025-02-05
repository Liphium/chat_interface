import 'package:get/get.dart';

enum MediaProfileType {
  static("media_profile.static"),
  motion("media_profile.motion"),
  balanced("media_profile.balanced");

  final String _label;
  String get label => _label.tr;

  const MediaProfileType(this._label);
}

class MediaProfile {
  final MediaProfileType type;
  final int width;
  final int height;
  final int framerate;
  final int bitrate;

  MediaProfile(this.type, this.width, this.height, this.framerate, this.bitrate);
}

class MediaProfiles {
  static const _kbps = 1000;

  static final staticMediaProfiles = <MediaProfile>[
    MediaProfile(MediaProfileType.static, 640, 360, 10, 1 * _kbps),
    MediaProfile(MediaProfileType.static, 854, 480, 12, 2 * _kbps),
    MediaProfile(MediaProfileType.static, 1280, 720, 15, 4 * _kbps),
    MediaProfile(MediaProfileType.static, 1600, 900, 15, 6 * _kbps),
    MediaProfile(MediaProfileType.static, 1920, 1080, 15, 8 * _kbps),
    MediaProfile(MediaProfileType.static, 2560, 1440, 15, 12 * _kbps),
    MediaProfile(MediaProfileType.static, 3840, 2160, 15, 16 * _kbps),
  ];

  static final motionMediaProfiles = <MediaProfile>[
    MediaProfile(MediaProfileType.motion, 640, 360, 30, 1 * _kbps),
    MediaProfile(MediaProfileType.motion, 854, 480, 45, 2 * _kbps),
    MediaProfile(MediaProfileType.motion, 1280, 720, 60, 4 * _kbps),
    MediaProfile(MediaProfileType.motion, 1600, 900, 45, 6 * _kbps),
    MediaProfile(MediaProfileType.motion, 1600, 900, 60, 8 * _kbps),
    MediaProfile(MediaProfileType.motion, 1920, 1080, 45, 10 * _kbps),
    MediaProfile(MediaProfileType.motion, 1920, 1080, 60, 12 * _kbps),
    MediaProfile(MediaProfileType.motion, 2560, 1440, 60, 16 * _kbps),
  ];

  static final balancedMediaProfiles = <MediaProfile>[
    MediaProfile(MediaProfileType.balanced, 640, 360, 24, 1 * _kbps),
    MediaProfile(MediaProfileType.balanced, 854, 480, 24, 2 * _kbps),
    MediaProfile(MediaProfileType.balanced, 1280, 720, 30, 4 * _kbps),
    MediaProfile(MediaProfileType.balanced, 1600, 900, 30, 6 * _kbps),
    MediaProfile(MediaProfileType.balanced, 1920, 1080, 30, 8 * _kbps),
    MediaProfile(MediaProfileType.balanced, 2560, 1440, 30, 12 * _kbps),
    MediaProfile(MediaProfileType.balanced, 3840, 2160, 30, 16 * _kbps),
  ];

  static final profiles = {
    MediaProfileType.static: staticMediaProfiles,
    MediaProfileType.motion: motionMediaProfiles,
    MediaProfileType.balanced: balancedMediaProfiles,
  };
}
