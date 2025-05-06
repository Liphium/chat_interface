import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_member.dart';
import 'package:chat_interface/services/connection/chat/stored_actions_listener.dart';
import 'package:chat_interface/services/connection/connection.dart';
import 'package:chat_interface/services/connection/messaging.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/encryption/hash.dart';
import 'package:chat_interface/util/encryption/signatures.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
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
  ConversationToken.fromJson(Map<String, dynamic> json) : id = LPHAddress.from(json["id"]), token = json["token"];

  String toJson(LPHAddress conv) => jsonEncode(toMap(conv));
  Map<String, dynamic> toMap(LPHAddress conv) => <String, dynamic>{
    "id": id.encode(),
    "conv": conv.encode(),
    "token": token,
    "time": -1,
  };
}

/// The container used for storing conversation data on the server.
///
/// For now it only stores the [name] of the conversation.
class ConversationContainer {
  late final String name;

  ConversationContainer(this.name);
  ConversationContainer.fromJson(Map<String, dynamic> json) : name = json["name"];

  factory ConversationContainer.decrypt(String cipherText, SecureKey key) {
    return ConversationContainer.fromJson(jsonDecode(decryptSymmetric(cipherText, key)));
  }
  String encrypted(SecureKey key) => encryptSymmetric(jsonEncode(toJson()), key);

  Map<String, dynamic> toJson() => <String, dynamic>{"name": name};
}

/// The prefix for the conversation name used for all direct messages
const directMessagePrefix = "DM_";

class ConversationService extends VaultTarget {
  ConversationService() : super(Constants.vaultConversationTag);

  @override
  Future<void> init() async {
    final conversations =
        await (db.select(db.conversation)..orderBy([(u) => drift.OrderingTerm.desc(u.updatedAt)])).get();
    final futures = <Future<void>>[];
    final order = List<LPHAddress>.filled(conversations.length, LPHAddress.error(), growable: true);
    final map = <LPHAddress, Conversation>{};
    int index = 0;
    for (var conversation in conversations) {
      // Make sure to handle the different types properly
      Conversation conv;
      switch (conversation.type) {
        case model.ConversationType.square:
          conv = Square.fromData(conversation);
        default:
          conv = Conversation.fromData(conversation);
      }

      // Load the members and add to the order and map
      futures.add(ConversationService.loadMembers(conv));
      map[conv.id] = conv;
      order[index] = conv.id;
      index++;
    }

    // Wait for the members to be loaded and then update the UI
    unawaited(
      futures.wait.then((_) {
        batch(() {
          ConversationController.order.value = order;
          ConversationController.conversations.value = map;
        });
      }),
    );
  }

  @override
  Future<void> processEntries(List<String> deleted, List<VaultEntry> newEntries) async {
    // Add all the new conversations to the vault
    for (var entry in newEntries) {
      // Make sure to handle both squares and conversations properly
      final json = jsonDecode(entry.payload);
      Conversation conv;
      if (json["type"] == model.ConversationType.square.index) {
        conv = Square.fromJson(json, entry.id);
      } else {
        conv = Conversation.fromJson(json, entry.id);
      }

      // Add to the controller in case not there yet
      if (ConversationController.conversations[conv.id] == null) {
        await ConversationService.insertFromVault(conv);
      }
    }

    // Delete everything that's been deleted from the vault on the server
    ConversationController.conversations.removeWhere((id, conv) {
      if (deleted.contains(conv.vaultId)) {
        ConversationService.delete(id, vaultId: conv.vaultId, deleteCache: false);
        ConversationController.order.remove(id);
        SidebarController.unselectConversation(id);
        return true;
      }
      return false;
    });

    // Subscribe to conversations again
    sendLog("vault sync completed");
    ConversationService.subscribeToConversations();
  }

  /// Open a direct message with a friend.
  ///
  /// The conversation is not null if there is one already.
  /// The string is an error if there was one.
  static Future<(Conversation?, String?)> openDirectMessage(Friend friend) async {
    // Check if the conversation already exists
    final conversation = ConversationController.conversations.values.firstWhere(
      (element) =>
          element.type == model.ConversationType.directMessage &&
          element.members.values.any((element) => element.address == friend.id),
      orElse:
          () => Conversation(
            LPHAddress.error(),
            "",
            model.ConversationType.directMessage,
            ConversationToken(LPHAddress.error(), ""),
            ConversationContainer(""),
            "",
            0,
            0,
            ConversationReads.fromContainer(""),
          ),
    );
    if (!conversation.id.isError()) {
      return (conversation, null);
    }

    // Open a new conversation with the friend
    return (
      null,
      await openConversation(model.ConversationType.directMessage, [
        friend,
      ], ConversationContainer(directMessagePrefix + friend.id.id)),
    );
  }

  /// Open a new group conversation.
  ///
  /// If the returned string is not null, it is an error message.
  static Future<String?> openGroupConversation(List<Friend> friends, String name) {
    return openConversation(model.ConversationType.group, friends, ConversationContainer(name));
  }

  /// The underlying method for creating a conversation on the server.
  static Future<String?> openConversation(
    model.ConversationType type,
    List<Friend> friends,
    ConversationContainer container,
  ) async {
    // Prepare the conversation
    final conversationKey = randomSymmetricKey();
    final ownMemberContainer = MemberContainer(StatusController.ownAddress).encrypted(conversationKey);
    final memberContainers = <LPHAddress, String>{};
    for (final friend in friends) {
      final container = MemberContainer(friend.id);
      memberContainers[friend.id] = container.encrypted(conversationKey);
    }
    final encryptedData = container.encrypted(conversationKey);

    // Create the conversation on the server
    final body = await postNodeJSON("/conversations/open", <String, dynamic>{
      "accountData": ownMemberContainer,
      "members": memberContainers.values.toList(),
      "type": type.index,
      "data": encryptedData,
    });
    if (!body["success"]) {
      return body["error"];
    }

    // Put together the information all other members need
    final packagedKey = packageSymmetricKey(conversationKey);
    final convId = LPHAddress.from(body["conversation"]);
    final conversation = Conversation(
      convId,
      "",
      model.ConversationType.values[body["type"]],
      ConversationToken.fromJson(body["admin_token"]),
      container,
      packagedKey,
      0,
      DateTime.now().millisecondsSinceEpoch,
      ConversationReads.fromContainer(""),
    );

    // Send all other members their information and credentials
    for (var friend in friends) {
      // Get the token for the member
      final token = ConversationToken.fromJson(body["tokens"][hashSha(memberContainers[friend.id]!)]);

      // Send them an authenticated stored action and add the member to the list
      final error = await sendAuthenticatedStoredAction(
        friend,
        _conversationPayload(convId, token, packagedKey, friend),
      );
      if (error != null) {
        // Handle invitation failure gracefully
        if (conversation.type == model.ConversationType.directMessage) {
          // In case of a direct message, delete it because we don't wanna be in there alone
          unawaited(delete(convId, token: conversation.token));
          return error;
        } else {
          // In case of a group conversation or square, simply remove the person
          final member = Member(token.id, friend.id, MemberRole.user);
          unawaited(member.remove(conversation));
        }
      }
    }

    // Add to vault
    final (error, _) = await addToVault(Constants.vaultConversationTag, conversation.toJson());
    if (error != null) {
      sendLog("WARNING: Conversation couldn't be added to vault: $error");
    }

    return null;
  }

  /// Delete/leave a conversation.
  ///
  /// If you want to delete it from the vault, specify [vaultId].
  /// If you want to also leave the conversation, specify [token].
  /// Deletion from the local database will always happen.
  /// Control deletion from the cache using [deleteCache].
  ///
  /// Returns an error if there was one.
  static Future<String?> delete(
    LPHAddress id, {
    String? vaultId,
    ConversationToken? token,
    bool deleteCache = true,
  }) async {
    // Remove the conversation from the vault (if desired)
    if (vaultId != null) {
      final err = await removeFromVault(vaultId);
      if (err != null) {
        return err;
      }
    }

    // Send a removal request to the server (if desired)
    if (token != null) {
      final json = await postNodeJSON("/conversations/leave", {"token": token.toMap(id)});

      if (!json["success"]) {
        sendLog("Error deleting conversation on the server, ignoring though: ${json["error"]}");
        // Don't return here, should remove from the local vault regardless
      }
    }

    // Remove the conversation from the local database
    await db.conversation.deleteWhere((tbl) => tbl.id.equals(id.encode()));
    await db.member.deleteWhere((tbl) => tbl.conversationId.equals(id.encode()));
    if (deleteCache) {
      SidebarController.unselectConversation(id);
      ConversationController.removeConversation(id);
    }
    return null;
  }

  /// Add a friend to a conversation by generating them a new token and sending it.
  ///
  /// Returns an error if there was one.
  static Future<String?> addToConversation(Conversation conv, Friend friend) async {
    // Generate a new conversation token for the friend
    final json = await postNodeJSON("/conversations/generate_token", {
      "token": conv.token.toMap(conv.id),
      "data": MemberContainer(friend.id).encrypted(conv.key),
    });
    if (!json["success"]) {
      return json["error"];
    }

    // Send the friend the invite to the conversation
    final result = await sendAuthenticatedStoredAction(
      friend,
      _conversationPayload(conv.id, ConversationToken.fromJson(json), packageSymmetricKey(conv.key), friend),
    );
    return result;
  }

  /// Create the stored action for a conversation invite.
  static Map<String, dynamic> _conversationPayload(
    LPHAddress id,
    ConversationToken token,
    String packagedKey,
    Friend friend,
  ) {
    final signature = signMessage(signatureKeyPair.secretKey, "$id${friend.id}");
    return authenticatedStoredAction("conv", {
      "id": id.encode(),
      "sg": signature,
      "token": token.toJson(id),
      "key": packagedKey,
    });
  }

  /// Ask the server to subscribe to all conversations.
  ///
  /// Also sends out status packets.
  static void subscribeToConversations({StatusController? controller}) {
    // Collect all thet tokens for the conversations currently in cache
    final tokens = <Map<String, dynamic>>[];
    for (var conversation in ConversationController.conversations.values) {
      tokens.add(conversation.token.toMap(conversation.id));
    }

    // Subscribe to all conversations
    unawaited(_sub(StatusController.statusPacket(), StatusController.sharedContentPacket(), tokens, deletions: true));
  }

  /// Ask the server to subscribe to a singular conversation.
  ///
  /// Also sends out a status packet to this conversation (if it's a direct message).
  static void subscribeToConversation(
    LPHAddress id,
    ConversationToken token, {
    StatusController? controller,
    deletions = true,
  }) {
    // Subscribe to all conversations
    final tokens = <Map<String, dynamic>>[token.toMap(id)];

    // Subscribe
    unawaited(
      _sub(StatusController.statusPacket(), StatusController.sharedContentPacket(), tokens, deletions: deletions),
    );
  }

  /// Returns an error if there was one.
  static Future<String?> _sub(
    String status,
    String statusData,
    List<Map<String, dynamic>> tokens, {
    deletions = false,
  }) async {
    // Get the sync dates for every conversation
    for (var token in tokens) {
      // Get the maximum value of the conversation update timestamps
      token["time"] = ConversationController.conversations[LPHAddress.from(token["conv"])]?.updatedAt ?? 0;
    }

    // Send the subscription request
    final event = await connector.sendActionAndWait(
      ServerAction("conv_sub", <String, dynamic>{"tokens": tokens, "status": status, "data": statusData}),
    );
    if (event == null) {
      return "server.error".tr;
    }
    if (!event.data["success"]) {
      sendLog("ERROR WHILE SUBSCRIBING: ${event.data["message"]}");
      return event.data["message"];
    }
    await ConversationController.finishedLoading(
      basePath,
      event.data["info"],
      deletions ? (event.data["missing"] ?? []) : [],
      false,
    );

    return null;
  }

  /// Add a new conversation to the cache from the vault.
  ///
  /// Inserts it into the database or updates it.
  /// Subscribes to the conversation.
  static Future<bool> insertFromVault(Conversation conversation) async {
    sendLog("new vault insertion");

    // Insert it into cache
    ConversationController.add(conversation);

    // Insert into database
    saveToDatabase(conversation, saveMembers: false);

    // Subscribe to conversation
    ConversationService.subscribeToConversation(conversation.id, conversation.token);

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
    final json = await postNodeJSON("/conversations/data", {"token": conversation.token.toMap(conversation.id)});
    if (!json["success"]) {
      sendLog("SOMETHING WENT WRONG KINDA WITH MEMBER FETCHING ${json["error"]}");
      conversation.membersLoading.value = false;
      return false;
    }

    // Make sure there are changes worth pulling
    if (conversation.lastVersion == json["version"]) {
      conversation.membersLoading.value = false;
      return true;
    }

    // Update to the latest version
    conversation.lastVersion = json["version"];

    // Update the container
    sendLog("conversation fetch with ${json["data"]}: ${conversation.container.name}");
    if (conversation.type == model.ConversationType.square) {
      conversation.container = SquareContainer.decrypt(json["data"], conversation.key);
    } else {
      conversation.container = ConversationContainer.decrypt(json["data"], conversation.key);
    }

    // Update the members
    final members = <LPHAddress, Member>{};
    for (var memberData in json["members"]) {
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
    batch(() {
      conversation.members.value = members;
      conversation.membersLoading.value = false;
      conversation.containerSub.value = conversation.container;
    });
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

  /// Update when the last message was read in a conversation.
  ///
  /// [messageSendTime] is when the message was sent.
  ///
  /// Also calls the same method in the controller.
  static void updateLastMessage(Conversation conversation, int stamp) {
    // Save the new update time in the local database
    final updatedTime = BigInt.from(stamp);
    final query =
        db.conversation.update()
          ..where((tbl) => tbl.id.equals(conversation.id.encode()) & tbl.updatedAt.isSmallerThanValue(updatedTime));
    unawaited(query.write(ConversationCompanion(updatedAt: drift.Value(updatedTime))));

    // Re-evaluate order in the sidebar
    ConversationController.reorder(conversation);
  }

  /// Get the notification count of a conversation (straight from the database).
  static Future<int> getNotificationCount(LPHAddress conversationId, int readAt, {String extra = ""}) async {
    final query =
        await db.message
            .count(
              where:
                  (row) =>
                      row.conversation.equals(withExtra(conversationId.encode(), extra)) &
                      row.createdAt.isBiggerThanValue(BigInt.from(readAt)),
            )
            .getSingle();
    return query;
  }

  /// Get the notification count of a conversation (straight from the database).
  static Future<BigInt> getUpdatedAt(LPHAddress conversationId) async {
    // Get the maximum value of the conversation update timestamps
    final max = db.message.createdAt.max(filter: db.message.conversation.like("%${conversationId.encode()}%"));
    final query = db.selectOnly(db.message)..addColumns([max]);

    return await query.map((row) => row.read(max)).getSingleOrNull() ?? BigInt.zero;
  }

  /// Mark the conversation as read for the current time.
  static Future<void> overwriteRead(Conversation conversation, int stamp, {String extra = ""}) async {
    // Build new reads
    final reads = ConversationReads.copy(conversation.reads);
    reads.map[ConversationReads.getContainerKey(extra)] = stamp;

    // Send new read state to the server
    final json = await postNodeJSON("/conversations/read", {
      "token": conversation.token.toMap(conversation.id),
      "data": reads.toContainer(),
    });

    if (json["success"]) {
      conversation.reads = reads;
      unawaited(evaluateNotificationCount(conversation));
    }
  }

  /// Process new reads when they come from the server (re-evaluate conversation count and more)
  static Future<void> evaluateNotificationCount(Conversation conversation) async {
    if (conversation is Square) {
      final squareContainer = conversation.container as SquareContainer;

      // Update for all topics
      for (var topic in [Topic("", "")] + squareContainer.topics) {
        final count = await getNotificationCount(conversation.id, conversation.reads.get(topic.id), extra: topic.id);
        ConversationController.updateNotificationCount(conversation.id, count, extra: topic.id);
      }
    } else {
      final count = await getNotificationCount(conversation.id, conversation.reads.getMain());
      ConversationController.updateNotificationCount(conversation.id, count);
    }
  }

  /// Load all members of a conversation into it from the local database.
  static Future<void> loadMembers(Conversation conv) async {
    // Get all the members from the local database
    final members = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(conv.id.encode()))).get();
    if (members.isEmpty) {
      sendLog("WARNING: a conversation doesn't have any members associated with it");
      return;
    }

    // Parse all of them from the database
    final map = <LPHAddress, Member>{};
    for (var dbMember in members) {
      final member = Member.fromData(dbMember);
      map[member.tokenId] = member;
    }

    // Set the members in the conversation
    conv.members.value = map;
  }

  /// Set the data of a conversation on the server.
  static Future<String?> setData(Conversation conv, ConversationContainer container) async {
    final data = container.encrypted(conv.key);

    // Update the conversation on the server
    final json = await postNodeJSON("/conversations/set_data", {
      "token": conv.token.toMap(conv.id),
      "data": {"version": conv.lastVersion, "data": data},
    });
    if (!json["success"]) {
      return json["error"];
    }

    // Update locally
    conv.lastVersion += 1;
    conv.container = container;
    conv.containerSub.value = container;

    return null;
  }

  /// Append an extra id to the conversation id (for message retrieval in sub channels)
  static String withExtra(String convId, String extra) {
    if (extra == "") {
      return convId;
    }
    return "${convId}_$extra";
  }
}

/// A simple helper class to store conversation reads
class ConversationReads {
  final map = <String, int>{};

  /// Parse as the format received from the server (use "" for empty conversation reads)
  ConversationReads.fromContainer(String container) {
    // Make sure to not parse no reads at all
    if (container == "") {
      return;
    }

    // Parse the reads from the container to the map
    final decrypted = decryptSymmetric(container, vaultKey);
    for (var entry in jsonDecode(decrypted).entries) {
      map[entry.key] = entry.value;
    }
  }

  /// Parse as the format received from the local database (use "" for empty conversation reads)
  ConversationReads.fromLocalContainer(String container) {
    // Make sure to not parse no reads at all
    if (container == "") {
      return;
    }

    // Parse the reads from the container to the map
    try {
      final decrypted = decryptSymmetric(container, databaseKey);
      for (var entry in jsonDecode(decrypted).entries) {
        map[entry.key] = entry.value;
      }
    } catch (_) {
      sendLog("ERROR: Local conversation read decryption failure");
      return;
    }
  }

  /// Copy another instance of [ConversationReads]
  ConversationReads.copy(ConversationReads reads) {
    for (var entry in reads.map.entries) {
      map[entry.key] = entry.value;
    }
  }

  /// Get all the reads in the form they're stored on the server.
  String toContainer() => encryptSymmetric(jsonEncode(map), vaultKey);

  /// Get all the reads in the form they're stored in the local database.
  String toLocalContainer() => encryptSymmetric(jsonEncode(map), databaseKey);

  /// Get the read time for an extra id.
  int get(String extra) {
    return map[getContainerKey(extra)] ?? 0;
  }

  /// Get the read time for the main conversation.
  int getMain() {
    return map[getContainerKey("")] ?? 0;
  }

  /// Get the key of a read time in any instance of [ConversationReads]
  static String getContainerKey(String extra) {
    return extra == "" ? "_" : extra;
  }
}
