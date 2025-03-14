import 'package:chat_interface/util/encryption/signatures.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/services/chat/unknown_service.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/spaces/space_service.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:signals/signals_flutter.dart';

class SpaceMemberController {
  static final membersLoading = signal(false);

  // Client ID -> SpaceMember
  static final members = mapSignal(<String, SpaceMember>{});

  // This is for caching only the account ids for message decryption
  static final memberIds = <String, LPHAddress>{}; // Client id -> Account id
  static String _ownId = "";

  /// Parse a member list and add it to the members map.
  static void onMembersChanged(List<dynamic> newMembers) {
    final membersFound = <String>[];

    // Start a batch to make sure members only updates after all the changes have been made
    batch(() {
      for (var member in newMembers) {
        final clientId = member["id"];
        final decrypted = decryptSymmetric(member["data"], SpaceController.key!);
        final address = LPHAddress.from(decrypted);
        if (address == StatusController.ownAddress) {
          _ownId = clientId;
        }
        membersFound.add(clientId);

        // Add the member to the list if they're not in it yet
        if (members[clientId] == null) {
          members[clientId] = SpaceMember(
            FriendController.friends[address] ?? (address == StatusController.ownAddress ? Friend.me() : Friend.unknown(address)),
            clientId,
          );
          members[clientId]!.verifySignature(member["sign"]);
        }

        // Cache the account id
        memberIds[clientId] = address;
      }

      // Remove everyone who left the space
      members.removeWhere((key, value) => !membersFound.contains(key));
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
    return members.peek()[clientId];
  }

  static void onDisconnect() {
    membersLoading.value = true;
    members.clear();
  }
}

class SpaceMember {
  final String id;
  final Friend friend;

  // We'll just keep this here for when Lightwire is finished
  final isSpeaking = signal(false);
  final isMuted = signal(false);
  final isDeafened = signal(false);
  final verified = signal(true);

  SpaceMember(this.friend, this.id);

  Future<void> verifySignature(String signature) async {
    // Load the guy's profile
    final profile = await UnknownService.loadUnknownProfile(friend.id);
    if (profile == null) {
      verified.value = false;
      sendLog("couldn't find profile: identity of space member is uncertain");
      return;
    }

    // Verify the signature
    try {
      final message = SpaceService.craftSignature(SpaceController.id.value!, id, friend.id.encode());
      verified.value = checkSignature(signature, profile.signatureKey, message);
      sendLog("space member verified: ${verified.value}");
    } catch (e) {
      sendLog("error with verifying space signature: $e");
      verified.value = false;
    }
  }
}
