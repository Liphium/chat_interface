import 'dart:async';

import 'package:chat_interface/controller/chat/conversation/call/output_controller.dart';
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

  final _outputs = <MediaDevice>[].obs;
  StreamSubscription<List<MediaDevice>>? _subscription;

  @override
  void initState() {
    super.initState();

    // Get microphones
    Hardware.instance.enumerateDevices(type: "audiooutput").then(_getMicrophones);

    // Subscribe to changes (e.g. unplugging a mic)
    _subscription = Hardware.instance.onDeviceChange.stream.listen(_getMicrophones);
  }

  void _getMicrophones(List<MediaDevice> list) {
    SettingController controller = Get.find();
    String currentMic = controller.settings["audio.output"]!.getValue();

    // Filter for microphones
    _outputs.clear();
    list.removeWhere((element) => element.kind != "audiooutput");

    // If the current microphone is not in the list, set it to default
    if(list.firstWhereOrNull((element) => element.label == currentMic) == null) {
      controller.settings["audio.output"]!.setValue("def");
    }

    _outputs.addAll(list);
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
        verticalSpacing(defaultSpacing * 0.5),

        //* Device selection
        Text("audio.output.device".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing * 0.5),

        RepaintBoundary(
          child: Obx(() =>
            ListView.builder(
              itemCount: _outputs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String current = _outputs[index].label;

                final first = index == 0;
                final last = index == _outputs.length - 1;
                
                final radius = BorderRadius.vertical(
                  top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                  bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                );
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.25, horizontal: defaultSpacing * 0.5),
                  child: Obx(() => 
                    Material(
                      color: controller.settings["audio.output"]!.getWhenValue("def", _outputs[0].label) == current ? theme.colorScheme.secondaryContainer :
                        theme.hoverColor,
                      borderRadius: radius,
                      child: InkWell(
                        borderRadius: radius,
                        onTap: () {
                          Get.find<PublicationController>().changeOutputDevice(_outputs[index]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(defaultSpacing),
                          child: Row(
                            children: [
                              //* Icon
                              Icon(Icons.speaker, color: theme.colorScheme.primary),

                              horizontalSpacing(defaultSpacing * 0.5),

                              //* Label
                              Text(_outputs[index].label, style: theme.textTheme.bodyMedium),
                            ],
                          )
                        ),
                      ),
                    )
                  ),
                );
              },
            )
          ),
        ),
        verticalSpacing(defaultSpacing),
      
        //* Audio test
        Text("audio.output.test".tr, style: theme.textTheme.labelLarge),

        Padding(
          padding: const EdgeInsets.all(defaultSpacing * 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("audio.output.test.description".tr, style: theme.textTheme.bodyMedium),
              horizontalSpacing(defaultSpacing * 0.5),
              ElevatedButton(
                onPressed: () => {}, // play audio
                child: Text("audio.output.test.play".tr, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      ],
    );
  }
}