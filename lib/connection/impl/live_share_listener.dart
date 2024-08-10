import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';

void setupLiveshareListening() {
  connector.listen("transaction_send_part", (event) {
    Get.find<ZapShareController>().sendFilePart(event);
  });

  connector.listen("transaction_end", (event) {
    sendLog("transaction cancelled :sad:");
    Get.find<ZapShareController>().onTransactionEnd();
  });
}
