
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/conversation_controller.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:get/get.dart';

import '../../../controller/chat/member_controller.dart';

// Action: setup_mem
void setupMemberListener(Event event) async {
  final conversation = event.data["conversation"];

  ConversationController conversationController = Get.find();
  FriendController controller = Get.find();

  // Add new members
  final memberList = <Member>[];
  for (var member in event.data["members"]) {
    
    String name = (controller.friends[member["account"]] ?? Friend(0, "fj-${member["account"]}", "tag")).name;
    final mem = Member.fromJson(name, member);
    await db.into(db.member).insertOnConflictUpdate(mem.toData(member["id"], conversation));

    memberList.add(mem);
  }

  conversationController.newMembers(conversation, memberList);

}