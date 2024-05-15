import 'dart:async';

import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../data/entities.dart';

class VideoSettings {
  static const String camera = "video.camera";
}

void addVideoSettings(SettingController controller) {
  controller.settings[VideoSettings.camera] = Setting<String>(VideoSettings.camera, "def");
}

class VideoSettingsPage extends StatefulWidget {
  const VideoSettingsPage({super.key});

  @override
  State<VideoSettingsPage> createState() => _VideoSettingsPageState();
}

class _VideoSettingsPageState extends State<VideoSettingsPage> {
  final _cameras = <MediaDevice>[].obs;
  StreamSubscription<List<MediaDevice>>? _subscription;

  @override
  void initState() {
    super.initState();

    // Get cameras
    Hardware.instance.enumerateDevices(type: "videoinput").then(_getMicrophones);

    // Subscribe to changes
    _subscription = Hardware.instance.onDeviceChange.stream.listen(_getMicrophones);
  }

  void _getMicrophones(List<MediaDevice> list) {
    SettingController controller = Get.find();
    String currentMic = controller.settings[VideoSettings.camera]!.getValue();

    // Filter for cameras
    _cameras.clear();
    list.removeWhere((element) => element.kind != "videoinput");

    // If the current camera is not in the list, set it to default
    if (list.firstWhereOrNull((element) => element.label == currentMic) == null) {
      controller.settings["video.camera"]!.setValue("def");
    }

    _cameras.addAll(list);
  }

  // Camera track
  final _cameraTrack = Rx<LocalVideoTrack?>(null);

  @override
  void dispose() async {
    _subscription?.cancel();
    super.dispose();
    await _cameraTrack.value?.stop();
  }

  MediaDevice _getDevice(String label) {
    return _cameras.firstWhere((element) => element.label == label);
  }

  void _startPreview(String label) async {
    if (_cameraTrack.value != null) {
      await _cameraTrack.value!.mute();
      await _cameraTrack.value!.stop();
    }

    // Start track
    _cameraTrack.value = await LocalVideoTrack.createCameraTrack(CameraCaptureOptions(deviceId: _getDevice(label).deviceId));
  }

  @override
  Widget build(BuildContext context) {
    SettingController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      //* Device selection
      Text("video.camera.device".tr, style: theme.textTheme.labelLarge),
      verticalSpacing(defaultSpacing),

      RepaintBoundary(
        child: Obx(
          () => Column(
            children: List.generate(_cameras.length, (index) {
              final current = _cameras[index].label;

              final first = index == 0;
              final last = index == _cameras.length - 1;

              final radius = BorderRadius.vertical(
                top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
              );

              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : elementSpacing),
                child: Obx(
                  () => Material(
                    color: controller.settings[VideoSettings.camera]!.getWhenValue("def", _cameras[0].label) == current
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onInverseSurface,
                    borderRadius: radius,
                    child: InkWell(
                      borderRadius: radius,
                      onTap: () async {
                        controller.settings[VideoSettings.camera]!.setValue(current);

                        // Refresh camera preview
                        if (_cameraTrack.value != null) {
                          _startPreview(_cameras[index].label);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Row(
                          children: [
                            //* Icon
                            Icon(Icons.camera_alt, color: theme.colorScheme.onPrimary),

                            horizontalSpacing(defaultSpacing * 0.5),

                            //* Label
                            Text(_cameras[index].label, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),

      verticalSpacing(sectionSpacing),
      Text("video.camera.preview".tr, style: theme.textTheme.labelLarge),
      verticalSpacing(defaultSpacing),

      //* Preview
      AspectRatio(
        aspectRatio: 16 / 5,
        child: Material(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(defaultSpacing),
          child: Obx(
            () => _cameraTrack.value == null
                ? Center(
                    child: FJElevatedButton(
                    shadow: true,
                    onTap: () async {
                      // Create new track
                      _startPreview(controller.settings["video.camera"]!.getWhenValue("def", _cameras[0].label));
                    },
                    child: Text("video.camera.preview.start".tr, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface)),
                  ))
                : VideoTrackRenderer(
                    _cameraTrack.value!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  ),
          ),
        ),
      )
    ]);
  }
}
