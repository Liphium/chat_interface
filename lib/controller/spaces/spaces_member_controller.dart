import 'package:chat_interface/util/encryption/signatures.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/unknown_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/services/spaces/space_service.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:signals/signals.dart';

class SpaceMemberController {
  static final membersLoading = signal(false);

  // Client ID -> SpaceMember
  static final members = signal(<String, SpaceMember>{});

  // This is for caching only the account ids for message decryption
  static final _memberIds = <String, LPHAddress>{}; // Client id -> Account id
  static String _ownId = "";

  /// Parse a member list and add it to the members map.
  static void onMembersChanged(List<dynamic> newMembers) {
    final statusController = Get.find<StatusController>();
    final membersFound = <String>[];

    // Start a batch to make sure members only updates after all the changes have been made
    batch(() {
      for (var member in newMembers) {
        final clientId = member["id"];
        final decrypted = decryptSymmetric(member["data"], SpacesController.key!);
        final address = LPHAddress.from(decrypted);
        if (address == StatusController.ownAddress) {
          _ownId = clientId;
        }
        membersFound.add(clientId);

        // Add the member to the list if they're not in it yet
        if (members.value[clientId] == null) {
          members.value[clientId] = SpaceMember(
            Get.find<FriendController>().friends[address] ??
                (address == StatusController.ownAddress ? Friend.me(statusController) : Friend.unknown(address)),
            clientId,
          );
          members.value[clientId]!.verifySignature(member["sign"]);
        }

        // Cache the account id
        _memberIds[clientId] = address;
      }

      // Remove everyone who left the space
      members.value.removeWhere((key, value) => !membersFound.contains(key));
    });

    // Update the signals
    membersLoading.value = false;
  }

  /// Get the id of the current client
  static String getOwnId() {
    return _ownId;
  }

  /// Get the Space member for a client id
  static SpaceMember? getMember(String clientId) {
    return members.value[clientId];
  }

  static void onDisconnect() {
    membersLoading.value = true;
    members.value = <String, SpaceMember>{};
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
      final message = SpaceService.craftSignature(SpacesController.id!, id, friend.id.encode());
      verified.value = checkSignature(signature, profile.signatureKey, message);
      sendLog("space member verified: ${verified.value}");
    } catch (e) {
      sendLog("error with verifying space signature: $e");
      verified.value = false;
    }
  }
}
