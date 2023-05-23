import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {

  final name = 'test'.obs;
  final tag = 'hi'.obs;
  final id = '0'.obs;

  // Status message
  final statusLoading = true.obs;
  final status = 'online'.obs;
  final type = 1.obs;

  void setName(String value) => name.value = value;
  void setTag(String value) => tag.value = value;
  void setId(String value) => id.value = value;

  void setStatus({String? message, int? type, Function()? success}) {
    if(statusLoading.value) return;
    statusLoading.value = true;

    // TODO: Encrypt
  
    // Send status to server
    connector.sendAction(Message("acc_st", <String, dynamic>{
      "status": message ?? status.value,
      "type": type ?? this.type.value,
    }), handler:(event) {
      statusLoading.value = false;
      if(event.data["success"]) {
        if(message != null) status.value = message;
        if(type != null) this.type.value = type;
        if(success != null) success();
      } else {
        showMessage(SnackbarType.error, "error.status.offline");
      }
    },);
  }

}