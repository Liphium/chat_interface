import 'package:chat_interface/pages/settings/app/language_settings.dart';
import 'package:chat_interface/pages/settings/app/spaces_settings.dart';
import 'package:chat_interface/pages/settings/app/speech_settings.dart';
import 'package:chat_interface/pages/settings/app/video_settings.dart';
import 'package:chat_interface/pages/settings/appearance/call_settings.dart';
import 'package:chat_interface/pages/settings/appearance/theme_settings.dart';
import 'package:chat_interface/pages/settings/data/entities.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {

  final settings = <String, Setting>{}; // label: Setting

  SettingController() {
    
    addSpeechSettings(this);
    addVideoSettings(this);
    addCallAppearanceSettings(this);
    addLanguageSettings(this);
    SpacesSettings.addSpacesSettings(this);
    ThemeSettings.addThemeSettings(this);
    
  }

  void addSetting(Setting setting) {
    settings[setting.label] = setting;
  }

}