import 'dart:async';

import 'package:chat_interface/controller/conversation/spaces/publication_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/pages/settings/components/bool_selection_small.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/settings_page_base.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/fj_slider.dart';
import 'package:chat_interface/theme/components/lph_tab_element.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'dart:io' as io;

import 'package:livekit_client/livekit_client.dart';

class AudioSettings {
  static String defaultDeviceName = "def";
  static const String microphone = "audio.microphone";
  static const String startMuted = "audio.microphone.muted";
  static const String output = "audio.output";

  // Microphone settings
  static const String noiseSuppression = "audio.microphone.noise_suppression";
  static const String autoGainControl = "audio.microphone.auto_gain_control";
  static const String echoCancellation = "audio.microphone.echo_cancellation";
  static const String typingNoiseDetection = "audio.microphone.typing_noise_detection";
  static const String highPassFilter = "audio.microphone.high_pass_filter";

  static const String microphoneSensitivity = "audio.microphone.sensitivity";

  static void addSettings(SettingController controller) async {
    //* Microphone
    controller.settings[AudioSettings.microphone] = Setting<String>(AudioSettings.microphone, AudioSettings.defaultDeviceName);
    controller.settings[AudioSettings.microphoneSensitivity] = Setting<double>(AudioSettings.microphoneSensitivity, -30);
    controller.settings[AudioSettings.startMuted] = Setting<bool>(AudioSettings.startMuted, false);
    controller.settings[AudioSettings.noiseSuppression] = Setting<bool>(AudioSettings.noiseSuppression, true);
    controller.settings[AudioSettings.autoGainControl] = Setting<bool>(AudioSettings.autoGainControl, true);
    controller.settings[AudioSettings.echoCancellation] = Setting<bool>(AudioSettings.echoCancellation, true);
    controller.settings[AudioSettings.typingNoiseDetection] = Setting<bool>(AudioSettings.typingNoiseDetection, true);
    controller.settings[AudioSettings.highPassFilter] = Setting<bool>(AudioSettings.highPassFilter, false);

    //* Output
    controller.settings[AudioSettings.output] = Setting<String>(AudioSettings.output, AudioSettings.defaultDeviceName);
  }
}

class AudioSettingsPage extends StatefulWidget {
  const AudioSettingsPage({super.key});

  @override
  State<AudioSettingsPage> createState() => _AudioSettingsPageState();
}

class _AudioSettingsPageState extends State<AudioSettingsPage> {
  final _selected = "audio.microphone".tr.obs;

  // Tabs
  final _tabs = <String, Widget>{
    "audio.microphone".tr: const MicrophoneTab(),
    "audio.output".tr: const OutputTab(),
  };

  @override
  Widget build(BuildContext context) {
    return SettingsPageBase(
      label: "audio",
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Tabs
          LPHTabElement(
            tabs: ["audio.microphone".tr, "audio.output".tr],
            onTabSwitch: (tab) {
              _selected.value = tab;
            },
          ),

          verticalSpacing(sectionSpacing),

          //* Current tab
          Obx(() => _tabs[_selected.value]!)
        ],
      ),
    );
  }
}

class MicrophoneTab extends StatefulWidget {
  const MicrophoneTab({super.key});

  @override
  State<MicrophoneTab> createState() => _MicrophoneTabState();
}

class _MicrophoneTabState extends State<MicrophoneTab> {
  final _microphones = <api.InputDevice>[].obs;
  final talking = false.obs;
  final windowsWarning = false.obs;
  final _sensitivity = 0.0.obs;
  bool _started = false;
  StreamSubscription? _sub, _actionSub;

  @override
  void initState() {
    super.initState();

    // Get microphones
    _init();
  }

  void _init() async {
    final list = await api.listInputDevices();
    SettingController controller = Get.find();
    String currentMic = controller.settings["audio.microphone"]!.getValue();

    // If the current microphone is not in the list, set it to default
    if (list.firstWhereOrNull((element) => element.id == currentMic) == null) {
      controller.settings["audio.microphone"]!.setValue("def");
    }

    _microphones.addAll(list);
    if (!Get.find<SpacesController>().connected.value) {
      await api.testVoice(device: _getCurrent(), detectionMode: 0);
      _started = true;
    } else {
      await api.setAmplitudeLogging(amplitudeLogging: true);
    }

    if (SpacesController.livekitRoom != null) {
      _actionSub = Get.find<SpaceMemberController>().members[SpaceMemberController.ownId]!.isSpeaking.listenAndPump((event) {
        talking.value = event;
      });
    } else {
      _actionSub = api.createActionStream().listen((event) {
        talking.value = event.action == SpaceMemberController.startedTalkingAction;
      });
    }
    api.setTalkingAmplitude(amplitude: controller.settings[AudioSettings.microphoneSensitivity]!.getValue() as double);

    _sub = api.createAmplitudeStream().listen((amp) {
      _sensitivity.value = amp;
    });

    if (io.Platform.isWindows) {
      tryGettingWindowsCommunicationsMode();
    }
  }

  String _getCurrent() {
    return Get.find<SettingController>().settings[AudioSettings.microphone]!.getOr(AudioSettings.defaultDeviceName);
  }

  void tryGettingWindowsCommunicationsMode() async {
    try {
      io.ProcessResult result = await io.Process.run(
        'powershell',
        [
          '-Command',
          'Get-ItemProperty -Path \'HKCU:\\Software\\Microsoft\\Multimedia\\Audio\' -Name UserDuckingPreference',
        ],
      );
      final args = result.stdout.toString().split("\n");
      final line = args[2].trim();
      final value = line.split(":")[1].trim();
      if (value != "3") {
        windowsWarning.value = true;
      }
    } catch (e) {
      sendLog("ERROR $e");
    }
  }

  Future<void> setUserDuckingPreference(int value) async {
    await io.Process.run(
      'powershell',
      [
        '-Command',
        'Set-ItemProperty -Path \'HKCU:\\Software\\Microsoft\\Multimedia\\Audio\' -Name UserDuckingPreference -Value $value',
      ],
    );
  }

  void _changeMicrophone(String device) async {
    Get.find<SettingController>().settings[AudioSettings.microphone]!.setValue(device);
    Get.find<PublicationController>().refreshMicrophone(device);
    api.setInputDevice(id: device);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _actionSub?.cancel();
    api.setAmplitudeLogging(amplitudeLogging: false);
    api.deleteAmplitudeStream();
    if (_started) {
      api.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingController controller = Get.find();
    final sens = controller.settings["audio.microphone.sensitivity"]!;
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //* Windows communications alert
        Obx(
          () => Animate(
            effects: [
              ExpandEffect(
                axis: Axis.vertical,
                alignment: Alignment.topLeft,
                curve: Curves.easeInOutBack,
                duration: 500.ms,
              ),
            ],
            target: windowsWarning.value ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: sectionSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(defaultSpacing),
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(defaultSpacing)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, color: Theme.of(context).colorScheme.onPrimary),
                        horizontalSpacing(defaultSpacing),
                        Flexible(
                          child: Text(
                            "audio.microphone.windows_warning".tr,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpacing(defaultSpacing),
                  FJElevatedButton(
                    smallCorners: true,
                    onTap: () {
                      windowsWarning.value = false;
                      setUserDuckingPreference(3);
                    },
                    child: Text("Fix my settings", style: Get.theme.textTheme.labelMedium),
                  ),
                ],
              ),
            ),
          ),
        ),

        //* Device selection
        Text("audio.device".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Text("audio.device.default".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),
        buildMicrophoneButton(
          controller,
          api.InputDevice(id: AudioSettings.defaultDeviceName, displayName: AudioSettings.defaultDeviceName, sampleRate: 48000, bestQuality: false),
          BorderRadius.circular(defaultSpacing),
          icon: Icons.done_all,
          label: "audio.device.default.button".tr,
        ),
        verticalSpacing(defaultSpacing - elementSpacing),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("audio.device.custom".tr, style: theme.textTheme.bodyMedium),
            verticalSpacing(elementSpacing),
            RepaintBoundary(
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_microphones.length, (index) {
                    final current = _microphones[index];

                    final first = index == 0;
                    final last = index == _microphones.length - 1;

                    final radius = BorderRadius.vertical(
                      top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                      bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                    );

                    return buildMicrophoneButton(controller, current, radius);
                  }),
                ),
              ),
            ),
          ],
        ),

        //* Start off muted
        const BoolSettingSmall(settingName: AudioSettings.startMuted),
        verticalSpacing(sectionSpacing),

        //* Sensitivity
        Text("audio.microphone.sensitivity".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),

        Text("audio.microphone.sensitivity.text".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(defaultSpacing),

        RepaintBoundary(
          child: Obx(
            () {
              return Column(
                children: [
                  // This boy is needed for the sensitvity to work for whatever reason
                  SizedBox(
                    height: 0,
                    child: Opacity(
                      opacity: 0,
                      child: Text(
                        _sensitivity.value.toString(),
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                  MicrophoneSensitivitySlider(
                    value: clampDouble(sens.value.value, -70, 0),
                    min: -70,
                    max: 0,
                    secondaryTrackValue: _sensitivity.value,
                    onChanged: (value) => sens.value.value = value,
                    onChangeEnd: (value) {
                      sens.setValue(value);
                      api.setTalkingAmplitude(amplitude: value);
                    },
                    label: "${(sens.value.value as double).toStringAsFixed(1)} dB",
                  ),
                ],
              );
            },
          ),
        ),

        verticalSpacing(defaultSpacing),
        Text("audio.microphone.sensitivity.audio_detector".tr, style: Get.theme.textTheme.bodyMedium),
        verticalSpacing(defaultSpacing),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: talking.value ? theme.colorScheme.secondary.withAlpha(150) : theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(elementSpacing),
            ),
            height: 15,
          ),
        ),

        verticalSpacing(sectionSpacing),

        //* Other settings
        Text("audio.microphone.processing".tr, style: theme.textTheme.labelLarge),
        verticalSpacing(defaultSpacing),
        Text("audio.microphone.processing.text".tr, style: theme.textTheme.bodyMedium),
        verticalSpacing(elementSpacing),

        const BoolSettingSmall(settingName: AudioSettings.echoCancellation),
        const BoolSettingSmall(settingName: AudioSettings.noiseSuppression),
        const BoolSettingSmall(settingName: AudioSettings.autoGainControl),
        const BoolSettingSmall(settingName: AudioSettings.typingNoiseDetection),
        const BoolSettingSmall(settingName: AudioSettings.highPassFilter),
      ],
    );
  }

  Widget buildMicrophoneButton(SettingController controller, api.InputDevice current, BorderRadius radius, {IconData? icon, String? label}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: elementSpacing),
      child: Obx(
        () => Material(
          color: controller.settings["audio.microphone"]!.getOr(AudioSettings.defaultDeviceName) == current.id
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.onInverseSurface,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              _changeMicrophone(current.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(defaultSpacing),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        //* Icon
                        Icon(icon ?? Icons.mic, color: Get.theme.colorScheme.onPrimary),

                        horizontalSpacing(defaultSpacing * 0.5),

                        //* Label
                        Text(label ?? current.displayName, style: Get.theme.textTheme.labelMedium),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: current.bestQuality,
                    child: Icon(Icons.verified, color: Get.theme.colorScheme.secondary),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MicrophoneSensitivitySlider extends StatelessWidget {
  final double secondaryTrackValue;
  final double value;
  final double min, max;
  final String label;

  final Function(double)? onChanged;
  final Function(double)? onChangeEnd;

  const MicrophoneSensitivitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.secondaryTrackValue,
    required this.label,
    this.min = 0.0,
    this.max = 1.0,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackShape: CustomSliderTrackShape(),
        thumbShape: CustomSliderThumbShape(),
        overlayShape: CustomSliderOverlayShape(),
        trackHeight: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sliderPercentage = (secondaryTrackValue - min) / (max - min);
                return Stack(
                  children: [
                    Slider(
                      value: value,
                      inactiveColor: Get.theme.colorScheme.primary,
                      thumbColor: Get.theme.colorScheme.onPrimary,
                      activeColor: Get.theme.colorScheme.onPrimary,
                      min: min,
                      max: max,
                      onChanged: onChanged,
                      onChangeEnd: onChangeEnd,
                    ),
                    IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: AnimatedContainer(
                          duration: 100.ms,
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.onSurface.withAlpha(150),
                            borderRadius: BorderRadius.circular(defaultSpacing),
                          ),
                          height: 8,
                          width: (constraints.maxWidth * sliderPercentage.clamp(0, 1)),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: defaultSpacing),
            child: Text(label),
          )
        ],
      ),
    );
  }
}

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
        buildOutputButton(controller, AudioSettings.defaultDeviceName, BorderRadius.circular(defaultSpacing),
            icon: Icons.done_all, label: "audio.device.default.button".tr),
        verticalSpacing(defaultSpacing - elementSpacing),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("audio.device.custom".tr, style: theme.textTheme.bodyMedium),
            verticalSpacing(elementSpacing),
            RepaintBoundary(
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_microphones.length, (index) {
                    final current = _microphones[index];

                    final first = index == 0;
                    final last = index == _microphones.length - 1;

                    final radius = BorderRadius.vertical(
                      top: first ? const Radius.circular(defaultSpacing) : Radius.zero,
                      bottom: last ? const Radius.circular(defaultSpacing) : Radius.zero,
                    );

                    return buildOutputButton(controller, current.label, radius);
                  }),
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
          color: controller.settings["audio.output"]!.getOr(AudioSettings.defaultDeviceName) == current
              ? Get.theme.colorScheme.primary
              : Get.theme.colorScheme.onInverseSurface,
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
