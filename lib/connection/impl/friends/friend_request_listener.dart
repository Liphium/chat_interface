
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/requests/requests_page.dart';
import 'package:get/get.dart';
import 'package:pointycastle/export.dart';

import '../../../controller/chat/friend_controller.dart';
import '../../../controller/chat/requests_controller.dart';
import '../../../util/snackbar.dart';

// Action: fr_rq:l
///* Handles friend requests sent to the user
void friendRequest(Event event) {
  
  int friendId = event.data["id"] as int;
  String name = event.data["name"];
  String signature = event.data["signature"];
  String publicKeyText = event.data["key"];
  RSAPublicKey publicKey = unpackagePublicKey(publicKeyText);
  String status = event.data["status"] as String;

  // Verify the signature
  if(!verifySignature(signature, publicKey, Get.find<StatusController>().name.value)) {

    // If the signature is invalid, deny the request
    if(status == "sent") {
      denyFriendRequest(friendId);
    }

    showMessage(SnackbarType.error, "fr_rq.invalid_signature".tr);
    return;
  }
  
  switch(status) {

    // If a request was sent, add it to the list
    case "sent":
      Get.find<RequestController>().requests.add(Request(name, event.data["tag"], publicKeyText, event.data["id"] as int));
      break;

    // If a request was accepted, add the friend to the list and remove the request
    case "accepted":
      Get.find<FriendController>().add(Friend(friendId, name, publicKeyText, event.data["tag"]));
      Get.find<RequestController>().requests.removeWhere((element) => element.id == friendId);     
      break;
  }

  showMessage(SnackbarType.success, "fr_rq.${event.data["status"]}".trParams({"name": name}));
}

// Action: fr_rq
///* Handles the response of a friend request action
void friendRequestStatus(Event event) {

  if(!event.data["success"]) {
    showMessage(SnackbarType.error, "fr_rq.${event.data["message"]}".tr);
  } else {

    String name = event.data["name"];
    if(event.data["message"] == "accepted") {
      int friendId = event.data["id"] as int;

      // Add the friend to the list and remove the request
      RequestController requestController = Get.find<RequestController>();
      Request request = requestController.requests.firstWhere((element) => element.id == friendId);

      Get.find<FriendController>().add(Friend(friendId, name, request.key, request.tag));
      requestController.requests.remove(request);
    }

    showMessage(SnackbarType.success, "fr_rq.${event.data["message"]}".trParams({"name": name}));
  }
}