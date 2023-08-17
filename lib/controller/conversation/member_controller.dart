import 'package:chat_interface/database/database.dart';
import 'package:get/get.dart';

class MemberController extends GetxController {

  final members = <Member>[].obs;

  void loadConversation(RxBool loading, String id) async {
    loading.value = true;

    final membersDb = await (db.select(db.member)..where((tbl) => tbl.conversationId.equals(id))).get();

    members.clear();
    members.addAll(membersDb.map((e) => Member.fromData(e)));

    //? old code for bigger conversations (maybe used for large chats in the future) (maybe move into isolate)
    // connector.sendAction(Message("conv_mem", <String, dynamic>{
    //   "id": id
    // }), handler: (event) async {
      
    //   // Check if request was successful
    //   if(!event.data["success"]) {
    //     showMessage(SnackbarType.error, "conv.error".tr);
    //     return;
    //   }

    //   members.clear();
    //   FriendController controller = Get.find();

    //   for(var member in event.data["members"]) {

    //     // Compute name (should be done in isolate)
    //     members.add(Member.fromJson(controller.friends.values.firstWhere((element) => element.id == member["account"],
    //     orElse: () => Friend(member["account"], "fj-${member["account"]}", "d")).name, member));
    //   }

    //   loading.value = false;
    
    //   // Save members to db
    //   for (var member in members) {
    //     await db.into(db.member).insertOnConflictUpdate(member.toData());
    //   }
    // });

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