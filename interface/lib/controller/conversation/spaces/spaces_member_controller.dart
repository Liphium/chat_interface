import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceMemberController extends GetxController {

  SecureKey? key;
  final membersLoading = false.obs;
  final members = <String, SpaceMember>{}.obs;

  void onMembersChanged(List<dynamic> members) {
    sendLog("members changed");
    final statusController = Get.find<StatusController>();
    final myId = statusController.id.value;
    for (var member in members) {
      final decrypted = decryptSymmetric(member, key!);
      sendLog(decrypted);
      if(this.members[decrypted] == null) {
        this.members[decrypted] = SpaceMember(Get.find<FriendController>().friends[decrypted] ?? (decrypted == myId ? Friend.me(statusController) : Friend.unknown(decrypted)));
      }
    }
    membersLoading.value = false;
  }

  void onConnect(SecureKey key) {
    this.key = key;
  }

  void onDisconnect() {
    membersLoading.value = true;
    members.clear();
  }

}

class SpaceMember {

  final Friend friend;
  
  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isDeafened = false.obs;

  SpaceMember(this.friend);

  void _onChanged() {
  }

  void disconnect() {
  }

}