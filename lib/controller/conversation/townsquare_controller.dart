import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class TownsquareController extends GetxController {
  final enabled = false.obs;

  final messages = <TownsquareMessage>[].obs;

  void updateEnabledState() {
    enabled.value =
        (Get.find<SettingController>().settings[DataSettings.socialFeatures]!.value.value ?? true) && Get.find<StatusController>().type.value != statusDoNotDisturb;
  }
}

class TownsquareMessage {}

class TownsquareMember {
  final String accountId;
  final String username;
  final SecureKey signatureKey;

  TownsquareMember(this.accountId, this.username, this.signatureKey);
}
