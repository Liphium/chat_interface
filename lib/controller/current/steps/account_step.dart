import 'dart:async';

import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:sodium_libs/sodium_libs.dart';

late SecureKey vaultKey;
late SecureKey profileKey;

class AccountStep extends ConnectionStep {
  AccountStep() : super('loading.account');

  /// A completer to wait until the keys are set.
  ///
  /// Instantiated in [FriendSyncTask].
  /// Completed when this setup is over.
  static Completer<void>? keyCompleter;

  @override
  Future<SetupResponse> load() async {
    // Get account from database
    final body = await postAuthorizedJSON("/account/me", <String, dynamic>{});
    final account = body["account"];

    if (!body["success"]) {
      return SetupResponse(error: body["error"]);
    }

    // Set all account data
    final uNameChanged = StatusController.name.value != account["username"];
    final dNameChanged = StatusController.displayName.value != account["display_name"];

    // Set the account id if there isn't one
    if (StatusController.ownAccountId == "" ||
        uNameChanged ||
        dNameChanged ||
        StatusController.ownAccountId != account["id"]) {
      sendLog("setting account id");
      await setEncryptedValue("cache_account_id", account["id"]);
      await setEncryptedValue("cache_account_uname", account["username"]);
      await setEncryptedValue("cache_account_dname", account["display_name"]);

      // Restart to migrate to the new account id
      return SetupResponse(restart: true);
    }

    // Set all permissions
    StatusController.permissions = List<String>.from(body["permissions"]);
    for (var rankJson in body["ranks"]) {
      StatusController.ranks.add(RankData.fromJson(rankJson));
    }

    // Decrypt the profile and vault key
    final vaultInfo = ServerStoredInfo.untransform(body["vault"]);
    final profileInfo = ServerStoredInfo.untransform(body["profile"]);
    if (profileInfo.error || vaultInfo.error) {
      return SetupResponse(error: "keys.invalid");
    }
    profileKey = unpackageSymmetricKey(profileInfo.text);
    vaultKey = unpackageSymmetricKey(vaultInfo.text);
    storedActionKey = body["actions"];

    // Set own key pair as cached (in the friend that represents this account)
    FriendController.friends[StatusController.ownAddress]!.setKeyStorage(
      KeyStorage(asymmetricKeyPair.publicKey, signatureKeyPair.publicKey, profileKey, ""),
    );

    // Tell the completer that the keys of the own friend have been set
    keyCompleter?.complete();

    return SetupResponse();
  }
}
