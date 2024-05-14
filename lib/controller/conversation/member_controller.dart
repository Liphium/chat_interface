import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';

class MemberController extends GetxController {
  final members = <Member>[].obs;

  void loadConversation(RxBool loading, String id) async {
    loading.value = true;

    final membersDb = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(id))).get();

    members.clear();
    members.addAll(membersDb.map((e) => Member.fromData(e)));
  }
}

class Member {
  final String tokenId; // Token id
  final String account; // Account id
  final MemberRole role;

  Member(this.tokenId, this.account, this.role);
  Member.unknown(this.account)
      : tokenId = "",
        role = MemberRole.user;
  Member.fromJson(Map<String, dynamic> json)
      : tokenId = json['id'],
        account = json['account'],
        role = MemberRole.fromValue(json['role']);

  Member.fromData(MemberData data) : this(data.id, data.accountId, MemberRole.fromValue(data.roleId));

  MemberData toData(String conversation) => MemberData(id: tokenId, accountId: account, roleId: role.value, conversationId: conversation);

  Friend getFriend([FriendController? controller]) {
    if (StatusController.ownAccountId == account) return Friend.me();
    controller ??= Get.find<FriendController>();
    return controller.friends[account] ?? Friend.unknown(account);
  }

  Future<bool> promote(String conversationId) async {
    final conversation = Get.find<ConversationController>().conversations[conversationId]!;
    final json = await postNodeJSON("/conversations/promote_token", {
      "id": conversation.token.id,
      "token": conversation.token.token,
      "user": tokenId,
    });

    if (!json["success"]) {
      return false;
    }

    return true;
  }

  Future<bool> demote(String conversationId) async {
    final conversation = Get.find<ConversationController>().conversations[conversationId]!;
    final json = await postNodeJSON("/conversations/demote_token", {
      "id": conversation.token.id,
      "token": conversation.token.token,
      "user": tokenId,
    });

    if (!json["success"]) {
      return false;
    }

    return true;
  }

  Future<bool> remove(String conversationId) async {
    final conversation = Get.find<ConversationController>().conversations[conversationId]!;
    final json = await postNodeJSON("/conversations/kick_member", {
      "id": conversation.token.id,
      "token": conversation.token.token,
      "target": tokenId,
    });

    if (!json["success"]) {
      sendLog(json["error"]);
      return false;
    }

    return true;
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
