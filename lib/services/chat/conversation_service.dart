import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/connection/chat/stored_actions_listener.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/encryption/hash.dart';
import 'package:chat_interface/util/encryption/signatures.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

/// The container used for storing members of conversations on the server
class MemberContainer {
  late final LPHAddress id;

  MemberContainer(this.id);
  MemberContainer.fromJson(Map<String, dynamic> json) : id = LPHAddress.from(json["id"]);

  /// Decrypts a [MemberContainer] received from the server using the conversation key.
  ///
  /// [key] is the encryption key of the conversation.
  MemberContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    id = LPHAddress.from(json["id"]);
  }

  /// Encrypt the member container for sending it to the server
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(<String, dynamic>{"id": id.encode()}), key);
}

/// The token for accessing a conversation and acting as a specific conversation member
class ConversationToken {
  final LPHAddress id;
  final String token;

  ConversationToken(this.id, this.token);
  ConversationToken.fromJson(Map<String, dynamic> json)
      : id = LPHAddress.from(json["id"]),
        token = json["token"];

  String toJson() => jsonEncode(toMap());
  Map<String, dynamic> toMap() => <String, dynamic>{"id": id.encode(), "token": token};
}

/// The container used for storing conversation data on the server.
///
/// For now it only stores the [name] of the conversation.
class ConversationContainer {
  late final String name;

  ConversationContainer(this.name);
  ConversationContainer.fromJson(Map<String, dynamic> json) : name = json["name"];

  ConversationContainer.decrypt(String cipherText, SecureKey key) {
    final json = jsonDecode(decryptSymmetric(cipherText, key));
    name = json["name"];
  }
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(<String, dynamic>{"name": name}), key);

  Map<String, dynamic> toJson() => <String, dynamic>{"name": name};
}

/// The prefix for the conversation name used for all direct messages
const directMessagePrefix = "DM_";

class ConversationService extends VaultTarget {
  ConversationService() : super(Constants.vaultConversationTag);

  @override
  Future<int> getLatestVersion() async {
    // Get the latest conersation entry version
    final max = db.conversation.vaultVersion.max();
    final query = db.selectOnly(db.conversation)..addColumns([max]);
    final maxValue = await query.map((row) => row.read(max)).getSingleOrNull();

    // Return zero in case nothing has been stored yet
    return maxValue?.toInt() ?? 0;
  }

  @override
  Future<void> init() async {
    final conversationController = Get.find<ConversationController>();
    final conversations = await (db.select(db.conversation)..orderBy([(u) => OrderingTerm.asc(u.updatedAt)])).get();
    for (var conversation in conversations) {
      await conversationController.add(Conversation.fromData(conversation));
    }
  }

  @override
  Future<void> processEntries(List<String> deleted, List<VaultEntry> newEntries) async {
    // Add all the new conversations to the vault
    final messageController = Get.find<MessageController>();
    final controller = Get.find<ConversationController>();
    for (var entry in newEntries) {
      final conv = Conversation.fromJson(jsonDecode(entry.payload), entry.id, entry.version);
      await ConversationService.updateOrInsertFromVault(conv);
    }

    // Delete everything that's been deleted from the vault on the server
    controller.conversations.removeWhere((id, conv) {
      if (deleted.contains(conv.vaultId)) {
        ConversationService.delete(id, vaultId: conv.vaultId, deleteLocal: false);
        controller.order.remove(id);
        messageController.unselectConversation(id: id);
        return true;
      }
      return false;
    });
  }

  /// Open a direct message with a friend.
  ///
  /// The conversation is not null if there is one already.
  /// The string is an error if there was one.
  static Future<(Conversation?, String?)> openDirectMessage(Friend friend) async {
    // Check if the conversation already exists
    final conversation = Get.find<ConversationController>().conversations.values.firstWhere(
          (element) => element.type == model.ConversationType.directMessage && element.members.values.any((element) => element.address == friend.id),
          orElse: () => Conversation(LPHAddress.error(), "", 0, model.ConversationType.directMessage, ConversationToken(LPHAddress.error(), ""),
              ConversationContainer(""), "", 0, 0),
        );
    if (!conversation.id.isError()) {
      return (conversation, null);
    }

    // Open a new conversation with the friend
    return (null, await _openConversation(model.ConversationType.directMessage, [friend], directMessagePrefix + friend.id.id));
  }

  /// Open a new group conversation.
  ///
  /// If the returned string is not null, it is an error message.
  static Future<String?> openGroupConversation(List<Friend> friends, String name) {
    return _openConversation(model.ConversationType.group, friends, name);
  }

  /// The underlying method for creating a conversation on the server.
  static Future<String?> _openConversation(model.ConversationType type, List<Friend> friends, String name) async {
    // Make sure the name of the conversation matches the requirements
    if (name.length > specialConstants[Constants.specialConstantMaxConversationNameLength]!) {
      return "conversations.name.length".trParams({
        "length": specialConstants[Constants.specialConstantMaxConversationNameLength].toString(),
      });
    }

    // Prepare the conversation
    final conversationKey = randomSymmetricKey();
    final ownMemberContainer = MemberContainer(StatusController.ownAddress).encrypted(conversationKey);
    final memberContainers = <LPHAddress, String>{};
    for (final friend in friends) {
      final container = MemberContainer(friend.id);
      memberContainers[friend.id] = container.encrypted(conversationKey);
    }
    final conversationContainer = ConversationContainer(name);
    final encryptedData = conversationContainer.encrypted(conversationKey);

    // Create the conversation on the server
    final body = await postNodeJSON("/conversations/open", <String, dynamic>{
      "accountData": ownMemberContainer,
      "members": memberContainers.values.toList(),
      "data": encryptedData,
    });
    if (!body["success"]) {
      return body["error"];
    }

    // Put together the information all other members need
    final packagedKey = packageSymmetricKey(conversationKey);
    final convId = LPHAddress.from(body["conversation"]);
    final conversation = Conversation(convId, "", 0, model.ConversationType.values[body["type"]], ConversationToken.fromJson(body["admin_token"]),
        conversationContainer, packagedKey, 0, DateTime.now().millisecondsSinceEpoch);

    // Send all other members their information and credentials
    for (var friend in friends) {
      // Get the token for the member
      final token = ConversationToken.fromJson(body["tokens"][hashSha(memberContainers[friend.id]!)]);

      // Send them an authenticated stored action and add the member to the list
      final error = await sendAuthenticatedStoredAction(friend, _conversationPayload(convId, token, packagedKey, friend));
      if (error != null) {
        unawaited(delete(convId, token: conversation.token));
        return error;
      }
    }

    // Add to vault
    final vaultId = await addToVault(Constants.vaultConversationTag, conversation.toJson());
    if (vaultId == null) {
      sendLog("WARNING: Conversation couldn't be added to vault");
    }

    return null;
  }

  /// Delete/leave a conversation.
  ///
  /// If you want to delete it from the vault, specify [vaultId].
  /// If you want to also leave the conversation, specify [token].
  /// Deletion from the local database and cache will always happen.
  ///
  /// Returns an error if there was one.
  static Future<String?> delete(LPHAddress id, {String? vaultId, ConversationToken? token, bool deleteLocal = true}) async {
    // Remove the conversation from the vault (if desired)
    if (vaultId != null) {
      final err = await removeFromVault(vaultId);
      if (err != null) {
        return err;
      }
    }

    // Send a removal request to the server (if desired)
    if (token != null) {
      final json = await postNodeJSON("/conversations/leave", {
        "token": token.toMap(),
      });

      if (!json["success"]) {
        sendLog("Error deleting conversation on the server, ignoring though: ${json["error"]}");
        // Don't return here, should remove from the local vault regardless
      }
    }

    // Remove the conversation from the local database
    await db.conversation.deleteWhere((tbl) => tbl.id.equals(id.encode()));
    await db.member.deleteWhere((tbl) => tbl.conversationId.equals(id.encode()));
    if (deleteLocal) {
      Get.find<MessageController>().unselectConversation(id: id);
      Get.find<ConversationController>().removeConversation(id);
    }
    return null;
  }

  /// Add a friend to a conversation by generating them a new token and sending it.
  ///
  /// Returns an error if there was one.
  static Future<String?> addToConversation(Conversation conv, Friend friend) async {
    // Generate a new conversation token for the friend
    final json = await postNodeJSON("/conversations/generate_token", {
      "token": conv.token.toMap(),
      "data": MemberContainer(friend.id).encrypted(conv.key),
    });
    if (!json["success"]) {
      return json["error"];
    }

    // Send the friend the invite to the conversation
    final result = await sendAuthenticatedStoredAction(
        friend, _conversationPayload(conv.id, ConversationToken.fromJson(json), packageSymmetricKey(conv.key), friend));
    return result;
  }

  /// Create the stored action for a conversation invite.
  static Map<String, dynamic> _conversationPayload(LPHAddress id, ConversationToken token, String packagedKey, Friend friend) {
    final signature = signMessage(signatureKeyPair.secretKey, "$id${friend.id}");
    return authenticatedStoredAction("conv", {
      "id": id.encode(),
      "sg": signature,
      "token": token.toJson(),
      "key": packagedKey,
    });
  }

  /// Ask the server to subscribe to all conversations.
  ///
  /// Also sends out status packets.
  static Future<bool> subscribeToConversations({StatusController? controller}) async {
    controller ??= Get.find<StatusController>();

    // Collect all thet tokens for the conversations currently in cache
    final tokens = <Map<String, dynamic>>[];
    for (var conversation in Get.find<ConversationController>().conversations.values) {
      tokens.add(conversation.token.toMap());
    }

    // Subscribe to all conversations
    unawaited(_sub(controller.statusPacket(), controller.sharedContentPacket(), tokens, deletions: true));
    return true;
  }

  /// Ask the server to subscribe to a singular conversation.
  ///
  /// Also sends out a status packet to this conversation (if it's a direct message).
  static void subscribeToConversation(ConversationToken token, {StatusController? controller, deletions = true}) {
    // Encrypt status with profile key
    controller ??= Get.find<StatusController>();

    // Subscribe to all conversations
    final tokens = <Map<String, dynamic>>[token.toMap()];

    // Subscribe
    unawaited(_sub(controller.statusPacket(), controller.sharedContentPacket(), tokens, deletions: deletions));
  }

  static Future<void> _sub(String status, String statusData, List<Map<String, dynamic>> tokens, {deletions = false}) async {
    // Get the maximum value of the conversation update timestamps
    final max = db.conversation.updatedAt.max();
    final query = db.selectOnly(db.conversation)..addColumns([max]);
    final maxValue = await query.map((row) => row.read(max)).getSingleOrNull();

    connector.sendAction(
        ServerAction("conv_sub", <String, dynamic>{
          "tokens": tokens,
          "status": status,
          "sync": maxValue?.toInt() ?? 0,
          "data": statusData,
        }), handler: (event) {
      if (!event.data["success"]) {
        sendLog("ERROR WHILE SUBSCRIBING: ${event.data["message"]}");
        return;
      }
      Get.find<StatusController>().statusLoading.value = false;
      Get.find<ConversationController>().finishedLoading(
        basePath,
        event.data["info"],
        deletions ? (event.data["missing"] ?? []) : [],
        false,
      );
    });
  }

  /// Add a new conversation to the cache from the vault.
  ///
  /// Inserts it into the database or updates it.
  /// Subscribes to the conversation.
  static Future<bool> updateOrInsertFromVault(Conversation conversation) async {
    // Insert it into cache
    await Get.find<ConversationController>().add(conversation, loadMembers: false);

    // Insert into database
    saveToDatabase(conversation, saveMembers: false);

    // Subscribe to conversation
    ConversationService.subscribeToConversation(conversation.token);

    return true;
  }

  /// Fetch all data about a conversation from the server and update it in the local database.
  ///
  /// Also compares the current version with the new version that was sent and doesn't refresh
  /// in case it's not nessecary.
  static Future<bool> fetchNewestVersion(Conversation conversation) async {
    if (conversation.membersLoading.value) {
      return false;
    }

    // Get the data from the server
    conversation.membersLoading.value = true;
    final json = await postNodeJSON("/conversations/data", {
      "token": conversation.token.toMap(),
    });

    if (!json["success"]) {
      sendLog("SOMETHING WENT WRONG KINDA WITH MEMBER FETCHING ${json["error"]}");
      return false;
    }

    // Make sure there are changes worth pulling
    if (conversation.lastVersion == json["version"]) {
      return true;
    }

    // Update to the latest version
    conversation.lastVersion = json["version"];

    // Update the container
    conversation.container = ConversationContainer.decrypt(json["data"], conversation.key);
    conversation.containerSub.value = conversation.container;

    // Update the members
    final members = <LPHAddress, Member>{};
    for (var memberData in json["members"]) {
      sendLog(memberData);
      final memberContainer = MemberContainer.decrypt(memberData["data"], conversation.key);
      final address = LPHAddress.from(memberData["id"]);
      members[address] = Member(address, memberContainer.id, MemberRole.fromValue(memberData["rank"]));
    }

    // Load the members into the database
    for (var currentMember in conversation.members.values) {
      if (!members.containsKey(currentMember.tokenId)) {
        await db.member.deleteWhere((tbl) => tbl.id.equals(currentMember.tokenId.encode()));
      }
    }

    // Set the members and save the conversation
    conversation.members.value = members;
    conversation.membersLoading.value = false;
    saveToDatabase(conversation);

    return true;
  }

  /// Save a conversation to the local database.
  ///
  /// By default members are also overwritten. Can be disabled by setting `saveMembers` to `false`.
  static void saveToDatabase(Conversation conversation, {saveMembers = true}) {
    db.conversation.insertOnConflictUpdate(conversation.entity);
    if (saveMembers) {
      for (var member in conversation.members.values) {
        db.member.insertOnConflictUpdate(member.toData(conversation.id));
      }
    }
  }
}
