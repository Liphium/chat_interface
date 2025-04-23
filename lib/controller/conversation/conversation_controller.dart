import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/services/chat/conversation_member.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sodium_libs/sodium_libs.dart';

class ConversationController {
  static final loaded = signal(false);
  static final order = listSignal(<LPHAddress>[]); // List of conversation IDs in order of last updated
  static final conversations = mapSignal(<LPHAddress, Conversation>{});
  static final notificationMap = mapSignal<String, int>({});
  int newConvs = 0;

  /// Add a conversation to the cache.
  static void add(Conversation conversation) {
    batch(() {
      _insertToOrder(conversation.id);
      conversations[conversation.id] = conversation;
    });
  }

  /// Update the last message send time of a conversation in the UI.
  ///
  /// For more explanation look at [ConversationService.updateLastMessage].
  static void updateLastMessageTime(
    LPHAddress conversation,
    int notificationCount, {
    String extra = "",
    required int messageSendTime,
  }) {
    batch(() {
      // Make sure the conversation is at the top
      _insertToOrder(conversation);

      // Update the notification count and updated at time of the conversation
      notificationMap[ConversationService.withExtra(conversation.encode(), extra)] = notificationCount;
      conversations[conversation]?.updatedAt = messageSendTime;
    });
  }

  /// Reset the notification count for a message.
  static void resetNotificationCount(LPHAddress conversation, {String extra = ""}) {
    notificationMap[ConversationService.withExtra(conversation.encode(), extra)] = 0;
  }

  /// Called when a subscription is finished to make sure conversations are properly sorted and up to date.
  ///
  /// Called later for all conversations from other servers since they are streamed in after.
  static Future<void> finishedLoading(
    String server,
    Map<String, dynamic> conversationInfo,
    List<dynamic> deleted,
    bool error,
  ) async {
    // Delete all the conversations that should be deleted
    for (var conversation in conversations.values) {
      if (deleted.contains(conversation.token.id.encode())) {
        unawaited(
          ConversationService.delete(conversation.id, vaultId: conversation.vaultId, token: conversation.token),
        );
      }
    }

    // Start a new batch to modify all the state at once
    batch(() {
      // Update all the conversations
      for (var conversation in conversations.values) {
        if (!isSameServer(conversation.id.server, server)) {
          continue;
        }

        // Get conversation info
        final info = (conversationInfo[conversation.id.encode()] ?? {}) as Map<dynamic, dynamic>;
        final version = (info["v"] ?? 0) as int;
        conversation.notificationCount.value = (info["n"] ?? 0) as int;
        conversation.readAt = (info["r"] ?? 0) as int;

        // Set an error if there is one
        if (error) {
          conversation.error.value = "other.server.error".tr;
        }

        // Check if the current version of the conversation is up to date
        if (conversation.lastVersion != version) {
          unawaited(ConversationService.fetchNewestVersion(conversation));
        }
      }

      loaded.value = true;
    });
  }

  /// Insert a conversation into the ordered list of conversations (performance could be improved using binary search).
  static void _insertToOrder(LPHAddress id) {
    batch(() {
      // Try to remove it from the ordered list
      var index = _findBinarySearch(id);
      if (index != -1) {
        order.removeAt(index);
      }

      // Dirty insert the conversation
      final readAt = conversations[id]!.readAt;
      index = 0;
      for (var id in order) {
        if (readAt > conversations[id]!.readAt) {
          break;
        }
        index++;
      }
      order.insert(index, id);
    });
  }

  /// Find a conversation id in the sorted order list using binary search.
  ///
  /// Returns -1 in case the thing wasn't found.
  static int _findBinarySearch(LPHAddress id) {
    return order.binarySearchBy(id, (conv) => conversations[conv]!.updatedAt);
  }

  /// Remove a conversation from the cache.
  static void removeConversation(LPHAddress id) {
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
  int updatedAt = 0;
  int readAt = 0;
  final notificationCount = signal(0);
  final containerSub = signal(ConversationContainer("")); // Data subscription
  final error = signal<String?>(null);
  String packedKey;
  SecureKey? _cachedKey;

  SecureKey get key {
    _cachedKey ??= unpackageSymmetricKey(packedKey);
    return _cachedKey!;
  }

  final membersLoading = signal(false);
  final members = mapSignal(<LPHAddress, Member>{}); // Token ID -> Member

  Conversation(
    this.id,
    this.vaultId,
    this.type,
    this.token,
    this.container,
    this.packedKey,
    this.lastVersion,
    this.updatedAt,
  ) {
    containerSub.value = container;
  }
  Conversation.fromJson(Map<String, dynamic> json, String vaultId)
    : this(
        LPHAddress.from(json["id"]),
        vaultId,
        model.ConversationType.values[json["type"]],
        ConversationToken.fromJson(json["token"]),
        ConversationContainer.fromJson(json["data"]),
        json["key"],
        0, // This shouldn't matter, just makes sure the data is fetched
        0,
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
      conversation.lastVersion,
      conversation.updatedAt,
    );

    // Copy all the members
    conv.members.addAll(conversation.members);

    return conv;
  }

  void addMember(Member member) {
    members[member.tokenId] = member;
  }

  bool get isGroup => type == model.ConversationType.group || type == model.ConversationType.square;

  /// Only works for direct messages
  String get dmName {
    final member = members.values.firstWhere(
      (element) => element.address != StatusController.ownAddress,
      orElse: () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user),
    );
    return FriendController.friends[member.address]?.displayName.value ?? container.name;
  }

  /// Only works for direct messages
  Friend get otherMember {
    final member = members.values.firstWhere(
      (element) => element.address != StatusController.ownAddress,
      orElse: () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user),
    );
    return FriendController.friends[member.address] ?? Friend.unknown(LPHAddress("-", container.name));
  }

  /// Check if a conversation is broken (borked)
  bool get borked =>
      !isGroup &&
      FriendController.friends[members.values
              .firstWhere(
                (element) => element.address != StatusController.ownAddress,
                orElse: () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user),
              )
              .address] ==
          null;

  ConversationData get entity {
    return ConversationData(
      id: id.encode(),
      vaultId: dbEncrypted(vaultId),
      type: type,
      data: dbEncrypted(jsonEncode(container.toJson())),
      token: dbEncrypted(token.toJson(id)),
      key: dbEncrypted(packageSymmetricKey(key)),
      lastVersion: BigInt.from(lastVersion),
      updatedAt: BigInt.from(updatedAt),
      readAt: BigInt.from(readAt),
    );
  }

  String toJson() => jsonEncode(<String, dynamic>{
    "id": id.encode(),
    "type": type.index,
    "token": token.toMap(id),
    "key": packageSymmetricKey(key),
    "data": container.toJson(),
  });

  /// Delete conversation from vault and database.
  ///
  /// Shows an error popup when there was an error.
  Future<void> delete({bool leaveRequest = true}) async {
    // Check if the vault id has been synchronized yet
    if (vaultId == "") {
      showErrorPopup("error", "conversation.delete_error".tr);
      sendLog("ERROR: Can't delete conversation yet: no vault id");
      return;
    }

    // Delete the conversation
    final error = await ConversationService.delete(id, vaultId: vaultId, token: leaveRequest ? token : null);
    if (error != null) {
      showErrorPopup("error", error);
      sendLog("ERROR: Can't delete conversation: $error");
    }
  }
}
