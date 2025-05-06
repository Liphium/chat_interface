import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/web.dart';

class Member {
  final LPHAddress tokenId; // Token id
  final LPHAddress address; // Account id
  final MemberRole role;

  Member(this.tokenId, this.address, this.role);
  Member.unknown(this.address) : tokenId = LPHAddress.error(), role = MemberRole.user;
  Member.fromJson(Map<String, dynamic> json)
    : tokenId = LPHAddress.from(json['id']),
      address = LPHAddress.from(json['address']),
      role = MemberRole.fromValue(json['role']);

  Member.fromData(MemberData data)
    : this(
        LPHAddress.from(data.id),
        LPHAddress.from(fromDbEncrypted(data.accountId)),
        MemberRole.fromValue(data.roleId),
      );

  MemberData toData(LPHAddress conversation) => MemberData(
    id: tokenId.encode(),
    accountId: dbEncrypted(address.encode()),
    roleId: role.value,
    conversationId: conversation.encode(),
  );

  Friend getFriend() {
    if (StatusController.ownAddress == address) return Friend.me();
    return FriendController.friends[address] ?? Friend.unknown(address);
  }

  /// Promote a member to the next available role.
  ///
  /// Returns an error if there was one.
  Future<String?> promote(Conversation conversation) async {
    final json = await postNodeJSON("/conversations/promote_token", {
      "token": conversation.token.toMap(conversation.id),
      "data": tokenId.encode(),
    });

    // Check if there was an error
    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }

  /// Demote a member to the next available role.
  ///
  /// Returns an error if there was one.
  Future<String?> demote(Conversation conversation) async {
    final json = await postNodeJSON("/conversations/demote_token", {
      "token": conversation.token.toMap(conversation.id),
      "data": tokenId.encode(),
    });

    // Check if there was an error
    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }

  /// Kick a member from the conversation.
  ///
  /// Returns an error if there was one.
  Future<String?> remove(Conversation conversation) async {
    // Kick the member's token out of the conversation
    final json = await postNodeJSON("/conversations/kick_member", {
      "token": conversation.token.toMap(conversation.id),
      "data": tokenId.encode(),
    });

    // Check if there was an error
    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }
}

enum MemberRole {
  admin(2),
  moderator(1),
  user(0);

  final int value;

  const MemberRole(this.value);

  bool lowerOrEqual(MemberRole role) {
    return value <= role.value;
  }

  bool higherOrEqual(MemberRole role) {
    return value >= role.value;
  }

  bool higherThan(MemberRole role) {
    return value > role.value;
  }

  bool lowerThan(MemberRole role) {
    return value < role.value;
  }

  static MemberRole fromValue(int value) {
    switch (value) {
      case 2:
        return MemberRole.admin;
      case 1:
        return MemberRole.moderator;
      case 0:
        return MemberRole.user;
    }
    return MemberRole.user;
  }
}
