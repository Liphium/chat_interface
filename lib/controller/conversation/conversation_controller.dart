import 'dart:convert';

import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/impl/setup_listener.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

import 'member_controller.dart';

part 'conversation_actions.dart';

class ConversationController extends GetxController {
  final loaded = false.obs;
  final order = <LPHAddress>[].obs; // List of conversation IDs in order of last updated
  final conversations = <LPHAddress, Conversation>{};
  int newConvs = 0;

  /// Add a conversation to the cache
  Future<bool> add(Conversation conversation, {loadMembers = true}) async {
    // Load members from the database
    if (conversation.members.isEmpty && loadMembers) {
      final members = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(conversation.id.encode()))).get();

      for (var member in members) {
        conversation.addMember(Member.fromData(member));
      }
    }

    // Insert into cache
    _insertToOrder(conversation.id);
    conversations[conversation.id] = conversation;

    return true;
  }

  /// Add a new conversation and refresh members (also subscribes)
  Future<bool> addFromVault(Conversation conversation) async {
    // Insert it into cache
    add(conversation, loadMembers: false);

    // Insert into database
    conversation.save(saveMembers: false);

    // Subscribe to conversation
    subscribeToConversation(conversation.token);

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
    final vaultId = await addToVault(Constants.vaultConversationTag, conversation.toJson());
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

  void updateMessageRead(LPHAddress conversation, {bool increment = true, required int messageSendTime}) {
    (db.conversation.update()..where((tbl) => tbl.id.equals(conversation.encode())))
        .write(ConversationCompanion(updatedAt: drift.Value(BigInt.from(DateTime.now().millisecondsSinceEpoch))));

    // Swap in the map
    _insertToOrder(conversation);
    conversations[conversation]!.updatedAt.value = DateTime.now().millisecondsSinceEpoch;
    if (increment && conversations[conversation]!.readAt.value < messageSendTime) {
      conversations[conversation]!.notificationCount.value += 1;
    }
  }

  /// Called when a subscription is finished to make sure conversations are properly sorted and up to date
  void finishedLoading(Map<String, dynamic> conversationInfo, List<dynamic> deleted, List<dynamic> error, {bool overwriteReads = true}) async {
    // Sort the conversations
    order.sort((a, b) => conversations[b]!.updatedAt.value.compareTo(conversations[a]!.updatedAt.value));

    // Delete all the conversations that should be deleted
    var toRemove = <LPHAddress>[];
    final controller = Get.find<ConversationController>();
    for (var conversation in controller.conversations.values) {
      if (deleted.contains(conversation.token.id.encode())) {
        toRemove.add(conversation.id);
      }
    }
    for (var key in toRemove) {
      sendLog("deleting $key");
      controller.conversations[key]!.delete(popup: false);
    }

    // Update all the conversations
    for (var conversation in conversations.values) {
      // Get conversation info
      final info = (conversationInfo[conversation.id.encode()] ?? {}) as Map<dynamic, dynamic>;
      final lastRead = (info["r"] ?? 0) as int;
      final version = (info["v"] ?? 0) as int;
      conversation.notificationCount.value = (info["n"] ?? 0) as int;

      // Set an error if there is one
      if (error.contains(conversation.id.server)) {
        conversation.error.value = "other.server.error".tr;
      }

      // Check if the current version of the conversation is up to date
      sendLog("version ${conversation.id} client: ${conversation.lastVersion}, server: $version");
      if (conversation.lastVersion != version) {
        sendLog("conversation version updated");
        await conversation.fetchData();
      }

      if (overwriteReads) {
        conversation.readAt.value = lastRead;
      } else if (lastRead != 0) {
        conversation.readAt.value = lastRead;
      }
    }

    loaded.value = true;
  }

  void _insertToOrder(LPHAddress id) {
    if (order.contains(id)) {
      order.remove(id);
    }
    order.insert(0, id);
  }

  void removeConversation(LPHAddress id) {
    conversations.remove(id);
    order.remove(id);
  }
}

class Conversation {
  final LPHAddress id;
  String vaultId;
  final model.ConversationType type;
  final ConversationToken token;
  ConversationContainer container;
  int lastVersion;
  final updatedAt = 0.obs;
  final readAt = 0.obs;
  final notificationCount = 0.obs;
  final containerSub = ConversationContainer("").obs; // Data subscription
  final error = Rx<String?>(null);
  String packedKey;
  SecureKey? _cachedKey;

  SecureKey get key {
    _cachedKey ??= unpackageSymmetricKey(packedKey);
    return _cachedKey!;
  }

  final membersLoading = false.obs;
  final members = <LPHAddress, Member>{}.obs; // Token ID -> Member

  Conversation(this.id, this.vaultId, this.type, this.token, this.container, this.packedKey, this.lastVersion, int updatedAt) {
    containerSub.value = container;
    this.updatedAt.value = updatedAt;
  }
  Conversation.fromJson(Map<String, dynamic> json, String vaultId)
      : this(
          LPHAddress.from(json["id"]),
          vaultId,
          model.ConversationType.values[json["type"]],
          ConversationToken.fromJson(json["token"]),
          ConversationContainer.fromJson(json["data"]),
          json["key"],
          json["update"] ?? DateTime.now().millisecondsSinceEpoch,
          0, // This shouldn't matter, just makes sure the data is fetched
        );
  Conversation.fromData(ConversationData data)
      : this(
          LPHAddress.from(data.id),
          fromDbEncrypted(data.vaultId),
          data.type,
          ConversationToken.fromJson(jsonDecode(fromDbEncrypted(data.token))),
          ConversationContainer.fromJson(jsonDecode(fromDbEncrypted(data.data))),
          fromDbEncrypted(data.key),
          data.lastVersion.toInt(),
          data.updatedAt.toInt(),
        );

  /// Copy a conversation without the `key`.
  ///
  /// If the key was actually used it would just thrown an error for
  /// being completely invalid.
  factory Conversation.copyWithoutKey(Conversation conversation) {
    final conv = Conversation(
      conversation.id,
      conversation.vaultId,
      conversation.type,
      conversation.token,
      conversation.container,
      "",
      conversation.updatedAt.value,
      conversation.lastVersion,
    );

    // Copy all the members
    conv.members.addAll(conversation.members);

    return conv;
  }

  void addMember(Member member) {
    members[member.tokenId] = member;
  }

  bool get isGroup => type == model.ConversationType.group;

  /// Only works for direct messages
  String get dmName {
    final member = members.values.firstWhere(
      (element) => element.address != StatusController.ownAddress,
      orElse: () => Member(
        LPHAddress.error(),
        LPHAddress.error(),
        MemberRole.user,
      ),
    );
    return Get.find<FriendController>().friends[member.address]?.displayName.value ?? container.name;
  }

  /// Only works for direct messages
  Friend get otherMember {
    final member = members.values.firstWhere(
      (element) => element.address != StatusController.ownAddress,
      orElse: () => Member(
        LPHAddress.error(),
        LPHAddress.error(),
        MemberRole.user,
      ),
    );
    return Get.find<FriendController>().friends[member.address] ?? Friend.unknown(LPHAddress("-", container.name));
  }

  /// Check if a conversation is broken (borked)
  bool get borked =>
      !isGroup &&
      Get.find<FriendController>().friends[members.values
              .firstWhere((element) => element.address != StatusController.ownAddress,
                  orElse: () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user))
              .address] ==
          null;

  ConversationData get entity {
    return ConversationData(
      id: id.encode(),
      vaultId: dbEncrypted(vaultId),
      type: type,
      data: dbEncrypted(jsonEncode(container.toJson())),
      token: dbEncrypted(token.toJson()),
      key: dbEncrypted(packageSymmetricKey(key)),
      lastVersion: BigInt.from(lastVersion),
      updatedAt: BigInt.from(updatedAt.value),
      readAt: BigInt.from(readAt.value),
    );
  }

  String toJson() => jsonEncode(<String, dynamic>{
        "id": id.encode(),
        "type": type.index,
        "token": token.toMap(),
        "key": packageSymmetricKey(key),
        "update": updatedAt.value.toInt(),
        "data": container.toJson(),
      });

  // Delete conversation from vault and database
  void delete({bool request = true, bool popup = true}) async {
    final err = await removeFromVault(vaultId);
    if (err != null) {
      sendLog("Error deleting conversation from vault: $err");
      if (popup) showErrorPopup("error".tr, "error.not_delete_conversation".tr);
      return;
    }

    if (request) {
      final json = await postNodeJSON("/conversations/leave", {
        "token": token.toMap(),
      });

      if (!json["success"]) {
        sendLog("Error deleting conversation from vault: ${json["error"]}");
        if (popup) showErrorPopup("error".tr, "error.not_delete_conversation".tr);
        // Don't return here, should remove from the local vault regardless
      }
    }

    db.conversation.deleteWhere((tbl) => tbl.id.equals(id.encode()));
    db.member.deleteWhere((tbl) => tbl.conversationId.equals(id.encode()));
    Get.find<MessageController>().unselectConversation(id: id);
    Get.find<ConversationController>().removeConversation(id);
  }

  /// Save the entire conversation to the local database.
  ///
  /// By default members are also overwritten. Can be disabled by setting `saveMembers` to `false`.
  void save({saveMembers = true}) {
    db.conversation.insertOnConflictUpdate(entity);
    if (saveMembers) {
      for (var member in members.values) {
        db.member.insertOnConflictUpdate(member.toData(id));
      }
    }
  }

  /// Fetch all data about a conversation from the server and update it in the local database.
  ///
  /// Also compares the current version with the new version that was sent and doesn't refresh
  /// in case it's not nessecary. Can be disabled by setting `refreshAnyway` to `false`.
  Future<bool> fetchData() async {
    if (membersLoading.value) {
      return false;
    }

    // Get the data from the server
    membersLoading.value = true;
    final json = await postNodeJSON("/conversations/data", {
      "token": token.toMap(),
    });

    if (!json["success"]) {
      sendLog("SOMETHING WENT WRONG KINDA WITH MEMBER FETCHING ${json["error"]}");
      // TODO: Add to some sort of error collection
      return false;
    }

    // Update to the latest version
    sendLog("PULLED VERSION ${json["version"]}");
    lastVersion = json["version"];

    // Update the container
    container = ConversationContainer.decrypt(json["data"], key);
    containerSub.value = container;

    // Update the members
    final members = <LPHAddress, Member>{};
    for (var memberData in json["members"]) {
      sendLog(memberData);
      final memberContainer = MemberContainer.decrypt(memberData["data"], key);
      final address = LPHAddress.from(memberData["id"]);
      members[address] = Member(address, memberContainer.id, MemberRole.fromValue(memberData["rank"]));
    }

    // Load the members into the database
    for (var currentMember in this.members.values) {
      if (!members.containsKey(currentMember.tokenId)) {
        db.member.deleteWhere((tbl) => tbl.id.equals(currentMember.tokenId.encode()));
      }
    }

    // Set the members and save the conversation
    this.members.value = members;
    membersLoading.value = false;
    save();

    return true;
  }
}
