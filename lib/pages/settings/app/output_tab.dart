import 'dart:io';

import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OutputTab extends StatefulWidget {
  const OutputTab({super.key});

  @override
  State<OutputTab> createState() => _OutputTabState();
}

class _OutputTabState extends State<OutputTab> {
  final _microphones = <String>[].obs;

  @override
  void initState() {
    super.initState();

    // Get microphones
    _init();
  }

  void _init() async {
    // TODO: Rework this to use Livekit
  }

  void _changeDevice(String device) async {
    Get.find<SettingController>().settings[SpeechSettings.output]!.setValue(device);
    await api.setOutputDevice(id: device);
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
        buildOutputButton(controller, SpeechSettings.defaultDeviceName, BorderRadius.circular(defaultSpacing), icon: Icons.done_all, label: "audio.device.default.button".tr),
        verticalSpacing(defaultSpacing),

        if (Platform.isLinux)
          const ErrorContainer(
            expand: true,
            message: "The output device selection is not available on Linux because the device list is currently broken. We're working on a better solution.",
          )
        else
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

                      return buildOutputButton(controller, current, radius);
                    },
                  ),
                ),
              ),
            ],
          ),

        /*

        Text("audio.output.device".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),

        RepaintBoundary(
          child: Obx(() => ListView.builder(
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

                  return buildOutputButton(controller, current, radius);
                },
              )),
        ),
        verticalSpacing(sectionSpacing),
        */
        // TODO: Some sort of audio test
      ],
    );
  }

  Widget buildOutputButton(SettingController controller, String current, BorderRadius radius, {IconData? icon, String? label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: elementSpacing * 0.5, horizontal: elementSpacing),
      child: Obx(
        () => Material(
          color: controller.settings["audio.output"]!.getOr(SpeechSettings.defaultDeviceName) == current ? Get.theme.colorScheme.primary : Get.theme.colorScheme.onBackground,
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
                  Text(label ?? current, style: Get.theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
