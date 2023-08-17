import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';

class SensitivityController extends GetxController {

  final talking = false.obs;
  final current = 0.0.obs; // For UI purposes
  final sensitivity = 0.0.obs;

  // Timers
  Timer? _timer, _renewTimer;

  // Recorders
  final Record _recorder1 = Record(), _recorder2 = Record();

  // Record parameters
  late final String _path1, _path2;
  final bool _useOne = false;
  int _lastTime = 0;

  SensitivityController() {

    // Setup paths
    _setupPaths();
  }

  void setup() {
    sensitivity.value = Get.find<SettingController>().settings["audio.microphone.sensitivity"]!.getValue();

    // Listen for changes
    Get.find<SettingController>().settings["audio.microphone.sensitivity"]!.value.listen((value) {
      sensitivity.value = value;
    });
  }

  void _setupPaths() async {
    final basePath = (await getApplicationSupportDirectory()).path;
    final tempPath = path.join(basePath, "temp");
    await Directory(tempPath).create();

    _path1 = path.join(tempPath, "temp_sens${Random().nextInt(100000).toRadixString(16)}.opus");
    _path2 = path.join(tempPath, "temp_sens${Random().nextInt(100000).toRadixString(16)}.opus");
  }

  void startListening() async {
    /*
    talking.value = false;
    _timer?.cancel();
    _renewTimer?.cancel();

    // Delete files
    try {
      await File(_path1).delete();
      await File(_path2).delete();
    } catch(e) {
      logger.e(e);
    }

    // Start recorder 1
    _useOne = true;
    _recorder.start(
      path: _path,
      encoder: AudioEncoder.opus,
      device: await _inputDevice()
    );

    _renewTimer = Timer.periodic(const Duration(minutes: 5), (timer) => restart());

    // Start listening
    _timer = _talkingTimer();

    // Listen for new microphone
    Get.find<SettingController>().settings["audio.microphone"]!.value.listen((value) async {
      restart();
    });
    */
  }

  void restart() async {
    /*

    // Switch recorders
    _timer?.cancel();
    await _recorder.stop();
    try {
      await File(_path).delete();
    } catch(e) {
      e.printError();
    }
    _useOne = !_useOne;

    // Start new recorder
    _recorder.start(
      path: _path,
      encoder: AudioEncoder.opus,
      device: await _inputDevice()
    );

    // Start new timer
    _timer = _talkingTimer();
    */

  }

  void stopListening() {
    /*
    talking.value = false;
    _timer?.cancel();
    _renewTimer?.cancel();
    _recorder.stop();
    */
  }

  Timer _talkingTimer() {
    return Timer.periodic(const Duration(milliseconds: 25), (timer) async {
      
      final amplitude = await _recorder.getAmplitude();
      current.value = amplitude.max;

      if (amplitude.max >= sensitivity.value) {
        talking.value = true;
        _lastTime = DateTime.now().millisecondsSinceEpoch;
      } else if(DateTime.now().millisecondsSinceEpoch - _lastTime > 300) {
        talking.value = false;
      }

    });
  }

  // Current recorder and path
  Record get _recorder => _useOne ? _recorder1 : _recorder2;
  String get _path => _useOne ? _path1 : _path2;

  // Current device
  Future<InputDevice> _inputDevice() async {
    final list = await _recorder.listInputDevices();
    final current = Get.find<SettingController>().settings["audio.microphone"]!.getValue();

    return list.firstWhereOrNull((element) => element.label == current) ?? list.first;
  }
}