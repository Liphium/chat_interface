import 'package:chat_interface/pages/settings/app/call/call_settings.dart';
import 'package:chat_interface/pages/settings/app/speech/speech_settings.dart';
import 'package:chat_interface/pages/settings/app/video/video_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {

  final settings = <String, Setting>{}; // label: Setting

  SettingController() {
    
    addSpeechSettings(this);
    addVideoSettings(this);
    addCallAppearanceSettings(this);
    
  }

  void addSetting(Setting setting) {
    settings[setting.label] = setting;
  }

}