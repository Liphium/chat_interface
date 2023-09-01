import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

import 'member_controller.dart';

part 'conversation_actions.dart';

class ConversationController extends GetxController {

  final loaded = false.obs;
  final conversations = <String, Conversation>{}.obs;
  int newConvs = 0;

  Future<bool> add(Conversation conversation) async {
    conversations[conversation.id] = conversation;

    if(conversation.members.isEmpty) {
      final members = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

      for(var member in members) {
        conversation.members.add(Member.fromData(member));
      }
    }

    return true;
  }

  Future<bool> addCreated(Conversation conversation, List<Friend> members, {Member? admin}) async {
    conversations[conversation.id] = conversation;

    for(var member in members) {
      conversation.members.add(Member(member.id, MemberRole.user));
    }
    if(admin != null) {
      conversation.members.add(admin);
    }

    return true;
  }

  void finishedLoading() {
    loaded.value = true;
  }

}

class Conversation {
  
  final String id;
  final ConversationContainer container;
  final containerSub = ConversationContainer("").obs; // Data subscription
  SecureKey key;

  final membersLoading = false.obs;
  final members = <Member>[].obs;

  Conversation(this.id, this.container, this.key) {
    containerSub.value = container;
  }
  Conversation.fromData(ConversationData data) : this(data.id, ConversationContainer.fromJson(jsonDecode(data.data)), unpackageSymmetricKey(data.key));

  // TODO: Replace
  String status(StatusController statusController, FriendController friendController) {
    
    if(members.length == 2) {
      String id = members.firstWhere((element) => element.account != statusController.id.value).account;
      return friendController.friends[id]!.status.value;
    } 

    return "status.offline".tr;
  }

  bool get isGroup => members.length > 2;

  ConversationData get entity => ConversationData(id: id, key: packageSymmetricKey(key), data: container.toJson(), updatedAt: BigInt.from(DateTime.now().millisecondsSinceEpoch));
}