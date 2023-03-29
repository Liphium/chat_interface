import 'package:chat_interface/pages/settings/app/speech/speech_settings.dart';
import 'package:chat_interface/pages/settings/app/video/video_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {

  final settings = <String, Setting>{}; // label: Setting

  String currentCategory = "";

  SettingController() {

    currentCategory = "speech";
    addSpeechSettings(this);

    currentCategory = "video";
    addVideoSettings(this);
    
  }

  void addSetting(Setting setting) {
    settings[setting.label] = setting;
  }

}