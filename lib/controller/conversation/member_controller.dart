import 'package:chat_interface/database/database.dart';
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

  final String account; // Account id
  final MemberRole role;

  Member(this.account, this.role);
  Member.fromJson(Map<String, dynamic> json) : 
    account = json['account'],
    role = MemberRole.fromValue(json['role']);
  
  Member.fromData(MemberData data) : this(data.accountId, MemberRole.fromValue(data.roleId));

  MemberData toData(String id, String conversation) => MemberData(id: id, accountId: account, roleId: role.value, conversationId: conversation);

}

enum MemberRole {
  admin(2),
  moderator(1),
  user(0);

  final int value;

  const MemberRole(this.value);

  static MemberRole fromValue(int value) {
    switch(value) {
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