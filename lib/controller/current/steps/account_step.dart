import 'dart:async';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/current/steps/stored_actions_step.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';

late SymmetricKey vaultKey;
late SymmetricKey profileKey;

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
      await setSetting("cache_account_id", account["id"]);
      await setSetting("cache_account_uname", account["username"]);
      await setSetting("cache_account_dname", account["display_name"]);

      // Restart to migrate to the new account id
      return SetupResponse(restart: true);
    }

    // Set all permissions
    StatusController.permissions = List<String>.from(body["permissions"]);
    for (var rankJson in body["ranks"]) {
      StatusController.ranks.add(RankData.fromJson(rankJson));
    }

    // Decrypt the profile and vault key
    final vaultInfo = await ServerStoredInfo.untransform(body["vault"]);
    final profileInfo = await ServerStoredInfo.untransform(body["profile"]);
    if (profileInfo.error || vaultInfo.error) {
      return SetupResponse(error: "keys.invalid");
    }
    final encProfileKey = await unpackageSymmetricKey(profileInfo.text);
    final encVaultKey = await unpackageSymmetricKey(vaultInfo.text);
    if (encProfileKey == null || encVaultKey == null) {
      return SetupResponse(error: "keys.invalid");
    }
    profileKey = encProfileKey;
    vaultKey = encVaultKey;
    storedActionKey = body["actions"];

    // Set own key pair as cached (in the friend that represents this account)
    FriendController.friends[StatusController.ownAddress]!.setKeyStorage(
      KeyStorage(asymmetricKeyPair.publicKey, signatureKeyPair.verifyingKey, profileKey, ""),
    );

    // Tell the completer that the keys of the own friend have been set
    keyCompleter?.complete();

    return SetupResponse();
  }
}
