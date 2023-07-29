
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:get/get.dart';

void setupStoredActionListener() {

  connector.listen("s_a", (event) {

    // Check if ID matches up (idk just for safety or something ig)
    if(event.data["id"] != Get.find<StatusController>().id.value) {
      print("something weird happened: id mismatch on a stored action");
      return;
    }

    // Decrypt stored action payload
    final payload = decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, event.data["payload"]);

    try {
      processStoredAction(payload);
    } catch(e) {
      print("something weird happened: error while processing stored action payload");
      print(e);
    }

  });

}

void processStoredAction(String payload) {
  
  final json = jsonDecode(payload);
  switch(json.action) {
    
    // Handle friend requests
    case "fr_rq":

      

      break;
  }

}