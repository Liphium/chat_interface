import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/controller/chat/friend_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:encrypt/encrypt.dart';
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
      ConversationData? data = await (db.select(db.conversation)..where((tbl) => tbl.id.equals(conv.id))).getSingleOrNull();

      if(data == null) {
        await db.into(db.conversation).insertOnConflictUpdate(conv.entity);
      } else {
        conv.key = data.key;
        await db.into(db.conversation).insertOnConflictUpdate(conv.entity);
      }

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
  final decrypted = "no".obs;
  String key;
  String data;

  final membersLoading = false.obs;
  final members = <Member>[].obs;

  Conversation(this.id, this.data, this.key);

  Conversation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        data = json["data"],
        key = "key";

  Conversation.fromData(ConversationData data) : this(data.id, data.data, data.key);

  String refreshName(StatusController statusController, FriendController friendController) {
    
    if(members.length == 2) {
      decrypted.value = members.firstWhere((element) => element.account != statusController.id.value).name;
      return decrypted.value;
    } 

    if(decrypted.value == "no" && key != "key") {
      try {
        decrypted.value = decryptAES(Encrypted.fromBase64(data), key);
      } catch (e) {
        decrypted.value = "no";
      }
    }

    return decrypted.value == "no" ? "loading".tr : decrypted.value;
  }

  String status(StatusController statusController, FriendController friendController) {
    
    if(members.length == 2) {
      int id = members.firstWhere((element) => element.account != statusController.id.value).account;
      return friendController.friends[id]!.status.value;
    } 

    return "status.offline".tr;
  }

  bool get isGroup => members.length > 2;

  ConversationData get entity => ConversationData(id: id, key: key, data: data, updatedAt: BigInt.from(DateTime.now().millisecondsSinceEpoch));
}