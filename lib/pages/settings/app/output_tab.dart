import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class OutputTab extends StatefulWidget {
  const OutputTab({super.key});

  @override
  State<OutputTab> createState() => _OutputTabState();
}

class _OutputTabState extends State<OutputTab> {
  final _microphones = <MediaDevice>[].obs;
  StreamSubscription<List<MediaDevice>>? _subscription;

  @override
  void initState() {
    super.initState();
    Hardware.instance.enumerateDevices().then(_onDeviceChange);
    _subscription = Hardware.instance.onDeviceChange.stream.listen(_onDeviceChange);
  }

  void _onDeviceChange(List<MediaDevice> devices) {
    _microphones.clear();
    _microphones.addAll(devices.where((element) => element.kind == "audiooutput").toList());
  }

  void _changeDevice(String device) async {
    final devices = await Hardware.instance.enumerateDevices();
    final output = devices.firstWhereOrNull((element) => element.label == device);
    if (output != null) {
      SpacesController.livekitRoom?.setAudioOutputDevice(output);
    }
    Get.find<SettingController>().settings[AudioSettings.output]!.setValue(device);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Device selection
        Text("audio.device".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Text("audio.device.default".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),
        buildOutputButton(controller, AudioSettings.defaultDeviceName, BorderRadius.circular(defaultSpacing), icon: Icons.done_all, label: "audio.device.default.button".tr),
        verticalSpacing(defaultSpacing - elementSpacing),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("audio.device.custom".tr, style: theme.textTheme.bodyMedium),
            verticalSpacing(elementSpacing),
            RepaintBoundary(
              child: Obx(
                () => ListView.builder(
                  itemCount: _microphones.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final current = _microphones[index];

                    final first = index == 0;
                    final last = index == _microphones.length - 1;

                    final radius = BorderRadius.vertical(
                      top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                      bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                    );

                    return buildOutputButton(controller, current.label, radius);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildOutputButton(SettingController controller, String current, BorderRadius radius, {IconData? icon, String? label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: elementSpacing),
      child: Obx(
        () => Material(
          color: controller.settings["audio.output"]!.getOr(AudioSettings.defaultDeviceName) == current ? Get.theme.colorScheme.primary : Get.theme.colorScheme.onBackground,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              _changeDevice(current);
            },
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Row(
                children: [
                  //* Icon
                  Icon(icon ?? Icons.mic, color: Get.theme.colorScheme.onPrimary),

                  horizontalSpacing(defaultSpacing * 0.5),

                  //* Label
                  Text(current, style: Get.theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
