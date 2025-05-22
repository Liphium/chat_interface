import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/services/chat/unknown_service.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/services/spaces/space_service.dart';
import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/util/encryption/packing.dart';
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
  static Future<void> onMembersChanged(List<dynamic> newMembers) async {
    final membersFound = <String>[];

    // Decrypt all of the account ids
    final accounts = await Future.wait(
      newMembers.map((e) {
        return decryptSymmetricBase64String(SpaceController.key!, e["data"]);
      }),
    );

    // Start a batch to make sure members only updates after all the changes have been made
    batch(() {
      int index = 0;
      for (var member in newMembers) {
        final clientId = member["id"];
        if (accounts[index] == null) {
          sendLog("WARNING: couldn't render one member of the space");
          continue;
        }
        final address = LPHAddress.from(accounts[index]!);
        if (address == StatusController.ownAddress) {
          _ownId = clientId;
        }
        membersFound.add(clientId);

        // Add the member to the list if they're not in it yet
        if (members[clientId] == null) {
          members[clientId] = SpaceMember(
            FriendController.friends[address] ??
                (address == StatusController.ownAddress ? Friend.me() : Friend.unknown(address)),
            clientId,
          );
          members[clientId]!.checkSignature(member["sign"]);
        }

        // Update their state
        members[clientId]!.connectedToStudio.value = member["st"];
        members[clientId]!.isMuted.value = member["mute"];
        members[clientId]!.isDeafened.value = member["deaf"];
        if (member["mute"] || member["deaf"] || !member["st"]) {
          members[clientId]!.talking.value = false;
        }

        // Cache the account id
        memberIds[clientId] = address;
        index++;
      }

      // Remove everyone who left the space
      members.removeWhere((key, value) => !membersFound.contains(key));

      // Update the signals
      membersLoading.value = false;
    });
  }

  /// Handle a change in talking state for a member
  static void handleTalkingState(String id, bool talking) {
    members[id]?.talking.value = talking;
  }

  /// Get the id of the current client
  static String getOwnId() {
    return _ownId;
  }

  /// Get the Space member for a client id
  static SpaceMember? getMember(String clientId) {
    return members[clientId];
  }

  static void onDisconnect() {
    membersLoading.value = true;
    members.clear();
  }
}

class SpaceMember {
  final String id;
  final Friend friend;

  // Lightwire and Studio state
  final talking = signal(false);
  DateTime? lastPacket;
  final connectedToStudio = signal(false);
  final isMuted = signal(false);
  final isDeafened = signal(false);
  final verified = signal(true);

  SpaceMember(this.friend, this.id);

  Future<void> checkSignature(String signature) async {
    // Load the guy's profile
    final profile = await UnknownService.loadUnknownProfile(friend.id);
    if (profile == null) {
      verified.value = false;
      sendLog("WARNING: couldn't find profile: identity of space member is uncertain");
      return;
    }

    // Verify the signature
    final message = SpaceService.craftSignature(SpaceController.id.value!, id, friend.id.encode());
    // signature, profile.signatureKey, message
    final decoded = decodeFromBase64(signature);
    if (decoded == null) {
      verified.value = false;
      sendLog("WARNING: space mmber couldn't be verified: coulnd't decode base64 signature");
      return;
    }
    verified.value =
        await verifySignature(key: profile.verifyKey, signature: packToBytes(message), message: decoded) ?? false;
    if (!verified.peek()) {
      sendLog("WARNING: space member not verified");
    }
  }
}
