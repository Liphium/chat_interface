
import 'package:chat_interface/pages/settings/data/settings_manager.dart';

import '../../data/entities.dart';

void addVideoSettings(SettingController controller) {

  controller.settings["video.camera"] = Setting<String>("video.camera", "def");
}