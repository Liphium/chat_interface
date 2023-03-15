import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:get/get.dart';

import '../current/status_controller.dart';
import 'member_controller.dart';

class ConversationController extends GetxController {

  final loaded = false.obs;
  final conversations = <int, Conversation>{}.obs;
  int newConvs = 0;

  void newConversations(dynamic conversations) async {
    if(conversations == null || conversations.length == 0) {
      finishedLoading();
      return;
    }

    newConvs = conversations.length;
    for (var conversation in conversations) {

      Conversation conv = Conversation.fromJson(conversation);
      await db.into(db.conversation).insertOnConflictUpdate(conv.entity);
      this.conversations[conv.id] = conv;
    }

    finishedLoading();
  }

  void newMembers(int id, List<Member> member) {
    newConvs--;
    if(newConvs == 0) {
      loaded.value = true;
    }

    if(conversations[id] == null) return;
    conversations[id]!.members.addAll(member);
  }

  void add(Conversation conversation) async {
    conversations[conversation.id] = conversation;

    if(conversation.members.isEmpty) {
      final members = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

      for(var member in members) {
        conversation.members.add(Member.fromData(member));
      }
    }
  }

  void finishedLoading() {
    loaded.value = true;
  }

}

class Conversation {
  
  final int id;
  final String data;

  final membersLoading = false.obs;
  final members = <Member>[].obs;

  Conversation(this.id, this.data);
  Conversation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        data = json["data"];

  Conversation.fromData(ConversationData data) : this(data.id, data.data);

  String getName(StatusController statusController, FriendController friendController) {

    if(members.length == 2) {
      return members.firstWhere((element) => element.account != statusController.id.value).name;
    } 

    return data;
  }

  bool get isGroup => members.length > 2;

  ConversationData get entity => ConversationData(id: id, data: data, updatedAt: BigInt.from(DateTime.now().millisecondsSinceEpoch));
}