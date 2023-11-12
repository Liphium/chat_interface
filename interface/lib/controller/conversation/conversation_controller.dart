import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/account/vault_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

import 'member_controller.dart';

part 'conversation_actions.dart';

class ConversationController extends GetxController {

  final loaded = false.obs;
  final order = <String>[].obs; // List of conversation IDs in order of last updated
  final conversations = <String, Conversation>{};
  int newConvs = 0;

  Future<bool> add(Conversation conversation) async {
    _insertToOrder(conversation.id);
    conversations[conversation.id] = conversation;

    if(conversation.members.isEmpty) {
      final members = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

      for(var member in members) {
        conversation.addMember(Member.fromData(member));
      }
    }

    return true;
  }

  Future<bool> addCreated(Conversation conversation, List<Member> members, {Member? admin}) async {
    conversations[conversation.id] = conversation;
    _insertToOrder(conversation.id);

    for(var member in members) {
      conversation.addMember(member);
    }
    if(admin != null) {
      conversation.addMember(admin);
    }

    // Add to vault
    await addToVault(Constants.conversationTag, conversation.toJson());

    // Store in database
    await db.conversation.insertOnConflictUpdate(conversation.entity);
    for(var member in conversation.members.values) {
      await db.member.insertOnConflictUpdate(member.toData(conversation.id));
    }

    return true;
  }

  void updateMessageRead(String conversation) {
    (db.conversation.update()..where((tbl) => tbl.id.equals(conversation))).write(ConversationCompanion(updatedAt: drift.Value(BigInt.from(DateTime.now().millisecondsSinceEpoch))));
    
    // Swap in the map
    _insertToOrder(conversation);
  }

  void finishedLoading() {
    // Sort the conversations
    order.sort((a, b) => conversations[b]!.updatedAt.value.compareTo(conversations[a]!.updatedAt.value));
    loaded.value = true;
  }

  void _insertToOrder(String id) {
    if(order.contains(id)) {
      order.remove(id);
    }
    order.insert(0, id);
  }

}

class Conversation {
  
  final String id;
  final ConversationToken token;
  final ConversationContainer container;
  final updatedAt = 0.obs;
  final readAt = 0.obs;
  final containerSub = ConversationContainer("").obs; // Data subscription
  SecureKey key;

  final membersLoading = false.obs;
  final members = <String, Member>{}.obs; // Token ID -> Member

  Conversation(this.id, this.token, this.container, this.key, int updatedAt, int readAt) {
    containerSub.value = container;
    this.updatedAt.value = updatedAt;
    this.readAt.value = readAt;
  }
  Conversation.fromJson(Map<String, dynamic> json) 
  : this(
    json["id"], 
    ConversationToken.fromJson(json["token"]), 
    ConversationContainer.fromJson(json["data"]), 
    unpackageSymmetricKey(json["key"]), 
    json["update"] ?? DateTime.now().millisecondsSinceEpoch,
    DateTime.now().millisecondsSinceEpoch
  );
  Conversation.fromData(ConversationData data) 
  : this(
    data.id, 
    ConversationToken.fromJson(jsonDecode(data.token)), 
    ConversationContainer.fromJson(jsonDecode(data.data)), 
    unpackageSymmetricKey(data.key),
    data.updatedAt.toInt(),
    data.readAt.toInt()
  );

  void addMember(Member member) {
    members[member.tokenId] = member;
  }

  bool get isGroup => !container.name.startsWith(directMessagePrefix);
  String get dmName => (Get.find<FriendController>().friends[members.values.firstWhere((element) => element.account != Get.find<StatusController>().id.value).account] ?? Friend.unknown(container.name)).name;  
  bool get borked => Get.find<FriendController>().friends[members.values.firstWhere((element) => element.account != Get.find<StatusController>().id.value).account] == null;

  ConversationData get entity => ConversationData(
    id: id, 
    token: token.toJson(), 
    key: packageSymmetricKey(key), 
    data: container.toJson(), 
    updatedAt: BigInt.from(updatedAt.value),
    readAt: BigInt.from(readAt.value)
  );
  String toJson() => jsonEncode(<String, dynamic>{
    "id": id,
    "token": token.toJson(),
    "key": packageSymmetricKey(key),
    "update": updatedAt.value.toInt(),
    "data": container.toJson(),
  });

  void delete() {
    // TODO: Delete on the server
    db.conversation.deleteWhere((tbl) => tbl.id.equals(id));
    db.message.deleteWhere((tbl) => tbl.conversationId.equals(id));
    db.member.deleteWhere((tbl) => tbl.conversationId.equals(id));
    Get.find<MessageController>().unselectConversation();
    Get.find<ConversationController>().conversations.remove(id);
  }
}