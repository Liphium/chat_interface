import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/conversation/conversation.dart' as model;
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/account/vault_setup.dart';
import 'package:chat_interface/pages/status/setup/account/key_setup.dart';
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

  /// Add a conversation to the cache
  Future<bool> add(Conversation conversation, {loadMembers = true}) async {
    // Insert into cache
    _insertToOrder(conversation.id);
    conversations[conversation.id] = conversation;

    // Load members from the database
    if (conversation.members.isEmpty && loadMembers) {
      final members = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(conversation.id))).get();

      for (var member in members) {
        conversation.addMember(Member.fromData(member));
      }
    }

    return true;
  }

  /// Add a new conversation and refresh members (also subscribes)
  Future<bool> addFromVault(Conversation conversation) async {
    // Insert it into cache
    add(conversation, loadMembers: false);

    // Insert into database
    conversation.save(fetchMembers: false);

    // Get all the members of the conversation
    var res = await conversation.fetchMembers(DateTime.fromMillisecondsSinceEpoch(0));
    if (!res) {
      return res;
    }

    // Subscribe to conversation
    subscribeToConversation(Get.find<StatusController>().statusJson(), conversation.token);

    return true;
  }

  /// Add a conversation to the cache and local database (after created)
  Future<bool> addCreated(Conversation conversation, List<Member> members, {Member? admin}) async {
    conversations[conversation.id] = conversation;
    _insertToOrder(conversation.id);

    for (var member in members) {
      conversation.addMember(member);
    }
    if (admin != null) {
      conversation.addMember(admin);
    }

    // Add to vault
    final vaultId = await addToVault(Constants.conversationTag, conversation.toJson());
    if (vaultId == null) {
      // TODO: refresh the vault or something
      sendLog("COULDNT STORE IN VAULT; SOMETHING WENT WRONG");
      return false;
    }
    conversation.vaultId = vaultId;
    sendLog("STORED IN VAULT: $vaultId");

    // Store in database
    await db.conversation.insertOnConflictUpdate(conversation.entity);
    for (var member in conversation.members.values) {
      await db.member.insertOnConflictUpdate(member.toData(conversation.id));
    }

    return true;
  }

  void updateMessageRead(String conversation, {bool increment = true, required int messageSendTime}) {
    (db.conversation.update()..where((tbl) => tbl.id.equals(conversation)))
        .write(ConversationCompanion(updatedAt: drift.Value(BigInt.from(DateTime.now().millisecondsSinceEpoch))));

    // Swap in the map
    _insertToOrder(conversation);
    conversations[conversation]!.updatedAt.value = DateTime.now().millisecondsSinceEpoch;
    if (increment && conversations[conversation]!.readAt.value < messageSendTime) {
      conversations[conversation]!.notificationCount.value += 1;
    }
  }

  void finishedLoading(Map<String, dynamic> readStates, List<dynamic> deleted, {bool overwriteReads = true}) async {
    // Sort the conversations
    order.sort((a, b) => conversations[b]!.updatedAt.value.compareTo(conversations[a]!.updatedAt.value));
    for (var conversation in conversations.values) {
      // Check if it was deleted
      if (deleted.contains(conversation.token.id)) {
        conversation.delete(request: false, popup: false);
        continue;
      }

      if (overwriteReads) {
        conversation.readAt.value = readStates[conversation.id] ?? 0;
      } else if (readStates[conversation.id] != null) {
        conversation.readAt.value = readStates[conversation.id];
      }
      conversation.fetchNotificationCount();
    }

    loaded.value = true;
  }

  void _insertToOrder(String id) {
    if (order.contains(id)) {
      order.remove(id);
    }
    order.insert(0, id);
  }

  void removeConversation(String id) {
    conversations.remove(id);
    order.remove(id);
  }
}

class Conversation {
  final String id;
  String vaultId;
  final model.ConversationType type;
  final ConversationToken token;
  final ConversationContainer container;
  final updatedAt = 0.obs;
  final readAt = 0.obs;
  final notificationCount = 0.obs;
  final containerSub = ConversationContainer("").obs; // Data subscription
  String packedKey;
  SecureKey? _cachedKey;

  get key {
    _cachedKey ??= unpackageSymmetricKey(packedKey);
    return _cachedKey;
  }

  final membersLoading = false.obs;
  final members = <String, Member>{}.obs; // Token ID -> Member

  Conversation(this.id, this.vaultId, this.type, this.token, this.container, this.packedKey, int updatedAt) {
    containerSub.value = container;
    this.updatedAt.value = updatedAt;
  }
  Conversation.fromJson(Map<String, dynamic> json, String vaultId)
      : this(
          json["id"],
          vaultId,
          model.ConversationType.values[json["type"]],
          ConversationToken.fromJson(json["token"]),
          ConversationContainer.fromJson(json["data"]),
          json["key"],
          json["update"] ?? DateTime.now().millisecondsSinceEpoch,
        );
  Conversation.fromData(ConversationData data)
      : this(
          data.id,
          data.vaultId,
          data.type,
          ConversationToken.fromJson(jsonDecode(data.token)),
          ConversationContainer.fromJson(jsonDecode(data.data)),
          data.key,
          data.updatedAt.toInt(),
        );

  void addMember(Member member) {
    members[member.tokenId] = member;
  }

  Future<bool> fetchNotificationCount() async {
    final count = await db.customSelect(
      "SELECT COUNT(*) AS c FROM message WHERE conversation_id = ? AND created_at > ?",
      variables: [drift.Variable.withString(id), drift.Variable.withBigInt(BigInt.from(readAt.value))],
      readsFrom: {db.message},
    ).getSingle();
    notificationCount.value += (count.data["c"] ?? 0) as int;
    return true;
  }

  bool get isGroup => type == model.ConversationType.group;

  String get dmName {
    final member = members.values.firstWhere(
      (element) => element.account != StatusController.ownAccountId,
      orElse: () => Member(
        StatusController.ownAccountId,
        StatusController.ownAccountId,
        MemberRole.user,
      ),
    );
    final friend = Get.find<FriendController>().friends[member.account] ?? Friend.unknown(container.name);
    return friend.displayName.value.text;
  }

  bool get borked =>
      !isGroup &&
      Get.find<FriendController>().friends[members.values
              .firstWhere((element) => element.account != StatusController.ownAccountId,
                  orElse: () => Member(StatusController.ownAccountId, StatusController.ownAccountId, MemberRole.user))
              .account] ==
          null;

  ConversationData get entity => ConversationData(
      id: id,
      vaultId: vaultId,
      type: type,
      token: token.toJson(),
      key: packageSymmetricKey(key),
      data: jsonEncode(container.toJson()),
      updatedAt: BigInt.from(updatedAt.value),
      readAt: BigInt.from(readAt.value));
  String toJson() => jsonEncode(<String, dynamic>{
        "id": id,
        "type": type.index,
        "token": token.toMap(),
        "key": packageSymmetricKey(key),
        "update": updatedAt.value.toInt(),
        "data": container.toJson(),
      });

  // Delete conversation from vault and database
  void delete({request = true, popup = true}) async {
    final err = await removeFromVault(vaultId);
    if (err != null) {
      sendLog("Error deleting conversation from vault: $err");
      if (popup) showErrorPopup("error".tr, "error.not_delete_conversation".tr);
      return;
    }

    if (request) {
      final json = await postNodeJSON("/conversations/leave", {
        "id": token.id,
        "token": token.token,
      });

      if (!json["success"]) {
        sendLog("Error deleting conversation from vault: ${json["error"]}");
        if (popup) showErrorPopup("error".tr, "error.not_delete_conversation".tr);
        return;
      }
    }

    db.conversation.deleteWhere((tbl) => tbl.id.equals(id));
    db.message.deleteWhere((tbl) => tbl.conversationId.equals(id));
    db.member.deleteWhere((tbl) => tbl.conversationId.equals(id));
    Get.find<MessageController>().unselectConversation(id: id);
    Get.find<ConversationController>().removeConversation(id);
  }

  void save({fetchMembers = true}) {
    db.conversation.insertOnConflictUpdate(entity);
    if (fetchMembers) {
      for (var member in members.values) {
        db.member.insertOnConflictUpdate(member.toData(id));
      }
    }
  }

  DateTime? lastMemberFetch; // Makes sure we only do it once when multiple methods call it

  // Re-fetch members of conversation (and save to database)
  Future<bool> fetchMembers(DateTime message) async {
    if (membersLoading.value) {
      return false;
    }

    if (lastMemberFetch != null) {
      // Just making sure, not sure if this is actually needed
      if (message.isBefore(lastMemberFetch!)) {
        return false;
      }
    }

    membersLoading.value = true;
    final json = await postNodeJSON("/conversations/tokens", {
      "id": token.id,
      "token": token.token,
    });

    sendLog("REFETCH");

    if (!json["success"]) {
      sendLog("SOMETHING WENT WRONG KINDA WITH MEMBER FETCHING");
      // TODO: Add to some sort of error collection
      return false;
    }

    final members = <String, Member>{};
    for (var memberData in json["members"]) {
      sendLog(memberData);
      final memberContainer = MemberContainer.decrypt(memberData["data"], key);
      members[memberData["id"]] = Member(memberData["id"], memberContainer.id, MemberRole.fromValue(memberData["rank"]));
    }

    for (var currentMember in this.members.values) {
      if (!members.containsKey(currentMember.tokenId)) {
        db.member.deleteWhere((tbl) => tbl.id.equals(currentMember.tokenId));
      }
    }

    this.members.value = members;
    membersLoading.value = false;
    save();

    lastMemberFetch = DateTime.now();
    return true;
  }
}
