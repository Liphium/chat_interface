import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:get/get.dart';

void setupStatusListener() {
  connector.listen("acc_st", (event) {

    final message = event.data["st"] as String;
    final status = message.split(":");
    final controller = Get.find<FriendController>();

    if(status.length != 2) {
      return;
    }

    final friend = controller.friendIdLookup[status[0]];
    if(friend == null) {
      return;
    }

    controller.friendIdLookup[status[0]]!.loadStatus(status[1]);

  }, afterSetup: true);
}