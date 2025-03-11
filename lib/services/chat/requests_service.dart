import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/account/friends/requests_controller.dart';
import 'package:chat_interface/services/chat/unknown_service.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/services/connection/chat/stored_actions_listener.dart';
import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class RequestsService {
  /// Called when the request is updated in the vault
  static void onVaultUpdateSent(Request request) {
    db.request.insertOnConflictUpdate(request.entity(true));
    Get.find<RequestController>().addSentRequestOrUpdate(request);
  }

  /// Called when the request is updated in the vault
  static void onVaultUpdate(Request request) {
    db.request.insertOnConflictUpdate(request.entity(false));
    Get.find<RequestController>().addRequestOrUpdate(request);
  }

  /// Send a friend request to an account or accept if sent before.
  ///
  /// First value in tuple is an error if there was one.
  /// Second value in tuple is the message if successful (request.accepted or request.sent).
  /// Both can also be null in case the vault is synchronizing.
  static Future<(String?, String?)> sendOrAcceptFriendRequest(UnknownAccount account) async {
    // Make sure the vault isn't being synchronized during a friend request
    if (FriendsVault.friendsVaultRefreshing.value) {
      return (null, null);
    }

    // Encrypt friend request
    final payload = storedAction("fr_rq", <String, dynamic>{
      "ad": StatusController.ownAddress.encode(),
      "pf": packageSymmetricKey(profileKey),
      "sa": storedActionKey,
      "s": encryptAsymmetricAuth(account.publicKey, asymmetricKeyPair.secretKey, account.name),
    });

    // Send stored action
    final result = await sendStoredAction(account.id, account.publicKey, payload);
    if (result != null) {
      return (result, null);
    }

    // Accept friend request if there is one from the other user
    final requestReceived = RequestController.requests[account.id];
    if (requestReceived != null) {
      // Make the request a friend in the vault
      final error = await FriendsVault.updateFriend(requestReceived.friend);
      if (error != null) {
        return (error, null);
      }

      return (null, "request.accepted".tr);
    } else {
      // Create the request
      final request = Request(
        account.id,
        account.name,
        account.displayName,
        "",
        KeyStorage(
          account.publicKey,
          account.signatureKey,
          profileKey,
          "",
        ),
        DateTime.now().millisecondsSinceEpoch,
      );

      // Store the request in the friends vault
      final error = await FriendsVault.storeSentRequest(
        request,
      );
      if (error != null) {
        requestsLoading.value = false;
        return (error, null);
      }

      return (null, "request.sent".tr);
    }
  }
}
