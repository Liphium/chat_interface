
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

void addSpeechSettings(SettingController controller) {

  controller.settings["audio.microphone"] = Setting<String>("audio.microphone", "def");
  controller.settings["audio.output"] = Setting<String>("audio.output", "def");

}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {

  final _microphones = [].obs;
  final _outputs = [].obs;

  @override
  void initState() {
    Hardware.instance.enumerateDevices(type: "audioinput").then((value) {
      _microphones.addAll(value);
    });
    Hardware.instance.enumerateDevices(type: "audiooutput").then((value) {
      _outputs.addAll(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SettingController controller = Get.find();
    ThemeData theme = Theme.of(context);

    Setting<String> microphone = controller.settings["audio.microphone"]! as Setting<String>;
    Setting<String> output = controller.settings["audio.output"]! as Setting<String>;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("settings.categories.audio".tr, style: theme.textTheme.headlineMedium),
        verticalSpacing(defaultSpacing),

        //* Microphone
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("audio.microphone".tr, style: theme.textTheme.titleMedium),
                verticalSpacing(defaultSpacing * 0.5),
                Text("audio.microphone.description".tr, style: theme.textTheme.bodyMedium),
              ],
            ),

            SizedBox(
              height: 40,
              child: Obx(() => 
                DropdownButton<String>(
                  value: _microphones.isEmpty ? "Loading.." : microphone.getWhenValue("def", _microphones[0].label),
                  underline: Container(),
                  elevation: 10,
                  alignment: Alignment.center,
                
                  onChanged: (String? newValue) {
                    microphone.setValue(newValue!);
                  },
              
                  items: _microphones.map((element) => element.label)
                  .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis,maxLines: 1,),
                  )).toList(),
                )
              ),
            ),
          ]
        ),
        verticalSpacing(defaultSpacing),

        //* Speakers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("audio.output".tr, style: theme.textTheme.titleMedium),
                verticalSpacing(defaultSpacing * 0.5),
                Text("audio.output.description".tr, style: theme.textTheme.bodyMedium),
              ],
            ),

            SizedBox(
              height: 40,
              child: Obx(() => 
                DropdownButton<String>(
                  value: _outputs.isEmpty ? "Loading." : output.getWhenValue("def", _outputs[0].label),
                  underline: Container(),
                  elevation: 10,
                  alignment: Alignment.center,
                
                  onChanged: (String? newValue) {
                    output.setValue(newValue!);
                  },
              
                  items: _outputs.map((element) => element.label)
                  .map((e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  )).toList(),
                )
              ),
            ),
          ]
        ),
      ],
    );
  }
}