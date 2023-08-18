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

  final String name;
  final String account;
  final int role;

  Member(this.name, this.account, this.role);
  Member.fromJson(this.name, Map<String, dynamic> json) : 
    account = json['account'],
    role = json['role'];
  
  Member.fromData(MemberData data) : this(data.name, data.accountId, data.roleId);

  MemberData toData(String id, String conversation) => MemberData(id: id, name: name, accountId: account, roleId: role, conversationId: conversation);

}