
import 'package:get/get.dart';
import 'package:drift/drift.dart' as drift;

import '../../../controller/chat/friend_controller.dart';
import '../../../database/database.dart';

void handleStoredAction(String action, String target) async {
  switch(action) {

    //* Handle removed friend
    case "fr_rem":
      
      Get.find<FriendController>().friends.removeWhere((id, friend) => id == int.parse(target));
      await db.delete(db.friend).delete(FriendCompanion(id: drift.Value(int.parse(target))));

      break;

    //* Handle removed conversation
    case "conv_rem":
      
      break;
  }
}