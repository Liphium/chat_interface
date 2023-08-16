
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:get/get.dart';

void setupSetupListeners() {

  //* New status
  connector.listen("setup_st", (event) {
    final data = event.data["data"]! as String;
    final controller = Get.find<StatusController>();
    controller.statusLoading.value = false;
    controller.status.value = data;
  });

  //* Setup finished
  connector.listen("setup_fin", (event) {
    logger.i("Setup finished");
  });
}