import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/services/spaces/space_service.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceMemberController extends GetxController {
  SecureKey? key;
  final membersLoading = false.obs;
  // Client ID -> SpaceMember
  final members = <String, SpaceMember>{}.obs;
  // This is for caching only the account ids for message decryption
  final memberIds = <String, LPHAddress>{}; // Client id -> Account id
  static String ownId = "";

  void onMembersChanged(List<dynamic> members) {
    final statusController = Get.find<StatusController>();
    final membersFound = <String>[];

    for (var member in members) {
      final clientId = member["id"];
      final decrypted = decryptSymmetric(member["data"], key!);
      final address = LPHAddress.from(decrypted);
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
        );
        this.members[clientId]!.verifySignature(member["sign"]);
      }

      // Cache the account id
      memberIds[clientId] = address;
    }

    // Remove everyone who left the space
    this.members.removeWhere((key, value) => !membersFound.contains(key));
    membersLoading.value = false;
  }

  Future<void> onConnect(SecureKey key) async {
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

  // We'll just keep this here for when Lightwire is finished
  final isSpeaking = false.obs;
  final isMuted = false.obs;
  final isDeafened = false.obs;
  final verified = true.obs;

  SpaceMember(this.friend, this.id);

  Future<void> verifySignature(String signature) async {
    // Load the guy's profile
    final profile = await Get.find<UnknownController>().loadUnknownProfile(friend.id);
    if (profile == null) {
      verified.value = false;
      sendLog("couldn't find profile: identity of space member is uncertain");
      return;
    }

    // Verify the signature
    try {
      final message = SpaceService.craftSignature(Get.find<SpacesController>().id.value, id, friend.id.encode());
      verified.value = checkSignature(signature, profile.signatureKey, message);
      sendLog("space member verified: ${verified.value}");
    } catch (e) {
      sendLog("error with verifying space signature: $e");
      verified.value = false;
    }
  }
}
