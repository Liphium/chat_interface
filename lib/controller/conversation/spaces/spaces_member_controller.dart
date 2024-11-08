import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceMemberController extends GetxController {
  SecureKey? key;
  final membersLoading = false.obs;
  final members = <String, SpaceMember>{}.obs;
  // This is for caching only the account ids for message decryption
  final memberIds = <String, LPHAddress>{}; // Client id -> Account id
  static String ownId = "";

  void onMembersChanged(List<dynamic> members) {
    sendLog("members changed");
    final statusController = Get.find<StatusController>();
    final membersFound = <String>[];

    // id = encryptedId:clientId
    // muted = bool
    // deafened = bool
    for (var member in members) {
      final args = member["id"].split(":");
      final decrypted = decryptSymmetric(args[0], key!);
      final address = LPHAddress.from(decrypted);
      final clientId = args[1];
      sendLog("$decrypted:$clientId");
      if (address == StatusController.ownAddress) {
        SpaceMemberController.ownId = clientId;
      }
      membersFound.add(clientId);

      // Add the member to the list if they're not in it yet
      if (this.members[clientId] == null) {
        this.members[clientId] = SpaceMember(
          Get.find<FriendController>().friends[address] ??
              (address == StatusController.ownAddress ? Friend.me(statusController) : Friend.unknown(address)),
          clientId,
          member["muted"],
          member["deafened"],
        );
      }

      // Cache the account id
      memberIds[clientId] = address;
    }

    // Remove everyone who left the space
    this.members.removeWhere((key, value) => !membersFound.contains(key));
    membersLoading.value = false;
  }

  void onConnect(SecureKey key) async {
    this.key = key;
  }

  void onDisconnect() {
    membersLoading.value = true;
    members.clear();
  }

  bool isLocalDeafened() {
    return members[ownId]!.isDeafened.value;
  }
}

class SpaceMember {
  final String id;
  final Friend friend;

  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isDeafened = false.obs;
  final isVideo = false.obs;
  final isScreenshare = false.obs;

  SpaceMember(this.friend, this.id, bool muted, bool deafened) {
    isMuted.value = muted;
    isDeafened.value = deafened;
  }
}
