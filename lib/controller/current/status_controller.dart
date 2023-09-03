import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {

  final name = 'test'.obs;
  final tag = 'hi'.obs;
  final id = '0'.obs;

  // Status message
  final statusLoading = true.obs;
  final status = '-'.obs; // "-" = status disabled
  final type = 1.obs;

  void setName(String value) => name.value = value;
  void setTag(String value) => tag.value = value;
  void setId(String value) => id.value = value;

  Future<bool> setStatus({String? message, int? type, Function()? success}) async {
    if(statusLoading.value) return false;
    statusLoading.value = true;
  
    final tokens = <Map<String, dynamic>>[]; // All conversation tokens
    for(final conversation in Get.find<ConversationController>().conversations.values) {
      if(!conversation.isGroup) {
        tokens.add(conversation.token.toMap());
      }
    }

    final encryptedStatus = encryptSymmetric(jsonEncode(<String, dynamic>{
      "status": message ?? status.value,
      "type": type ?? this.type.value,
    }), profileKey);

    // Send status to server
    final json = await postNodeJSON("/status", <String, dynamic>{
      "tokens": tokens,
      "status": encryptedStatus
    });
    statusLoading.value = false;
    if(!json["success"]) {
      return false;
    }

    if(message != null) status.value = message;
    if(type != null) this.type.value = type;
    if(success != null) success();
    return true;
  }

}