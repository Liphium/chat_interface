import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart' as msg;
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class TownsquareController extends GetxController {
  final enabled = false.obs;
  final connecting = false.obs;
  final inView = false.obs;

  final messages = <TownsquareMessage>[].obs;

  void updateEnabledState() {
    final before = enabled.value;
    enabled.value = (Get.find<SettingController>().settings[DataSettings.socialFeatures]!.value.value ?? true) &&
        Get.find<StatusController>().type.value != statusDoNotDisturb;
    if (before == enabled.value) {
      return;
    }

    if (enabled.value) {
      connecting.value = true;
      connector.sendAction(
        Message("townsquare_join", {}),
        handler: (event) {
          if (!event.data["success"]) {
            showErrorPopup("error", "townsquare.connection_error".tr);
            return;
          }
          connecting.value = false;
        },
      );
    } else {
      connector.sendAction(Message("townsquare_leave", {}));
    }
  }

  void view() {
    Get.find<msg.MessageController>().unselectConversation();
    inView.value = true;
  }

  void close() {
    inView.value = false;
  }
}

class TownsquareMessage {}

class TownsquareMember {
  final String accountId;
  final String username;
  final SecureKey signatureKey;

  TownsquareMember(this.accountId, this.username, this.signatureKey);
}
