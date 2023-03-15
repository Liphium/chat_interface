
import 'package:chat_interface/connection/messaging.dart';
import 'package:get/get.dart';

import '../../../controller/chat/friend_controller.dart';
import '../../../controller/chat/requests_controller.dart';
import '../../../util/snackbar.dart';

// Action: fr_rq:l
///* Handles friend requests sent to the user
void friendRequest(Event event) {
  
  int friendId = event.data["id"] as int;
  String name = event.data["name"];
  
  switch(event.data["status"] as String) {

    // If a request was sent, add it to the list
    case "sent":
      Get.find<RequestController>().requests.add(Request(name, event.data["tag"], event.data["id"] as int));
      break;

    // If a request was accepted, add the friend to the list and remove the request
    case "accepted":
      Get.find<FriendController>().add(Friend(friendId, name, event.data["tag"]));
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

      Get.find<FriendController>().add(Friend(friendId, name, event.data["tag"]));
      Get.find<RequestController>().requests.removeWhere((element) => element.id == friendId);
    }

    showMessage(SnackbarType.success, "fr_rq.${event.data["message"]}".trParams({"name": name}));
  }
}