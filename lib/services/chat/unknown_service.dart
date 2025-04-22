import 'dart:convert';

import 'package:chat_interface/util/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';

class UnknownService {
  /// Load the profile of an unknown account by name
  static Future<UnknownAccount?> getUnknownProfileByName(String name) async {
    // Ignore if it is the name of the current account
    if (StatusController.name.value == name) {
      return UnknownAccount(
        StatusController.ownAddress,
        name,
        "",
        signatureKeyPair.publicKey,
        asymmetricKeyPair.publicKey,
      );
    }

    // Get account
    final json = await postAuthorizedJSON("/account/get_name", {"name": name});

    // Check if it was successful
    if (!json["success"]) {
      sendLog("couldn't retrieve account $name because of: ${json["error"]}");
      return null;
    }

    // Parse the response into an unknown account
    final profile = UnknownAccount(
      LPHAddress(basePath, json["id"]),
      json["name"],
      json["display_name"],
      unpackagePublicKey(json["sg"]),
      unpackagePublicKey(json["pub"]),
    );

    return profile;
  }

  /// Load the profile of someone unknown
  static Future<UnknownAccount?> loadUnknownProfile(LPHAddress address) async {
    // Ignore if it is the id of the current account
    if (address == StatusController.ownAddress) {
      return UnknownAccount(
        StatusController.ownAddress,
        "",
        "",
        signatureKeyPair.publicKey,
        asymmetricKeyPair.publicKey,
      );
    }

    // If the id matches a friend, use that instead
    final friend = FriendController.friends[address];
    if (friend != null) {
      return UnknownAccount.fromFriend(friend);
    }

    // Make sure the server is trusted
    if (!await TrustedLinkHelper.askToAddIfNotAdded(address.server)) {
      return null;
    }

    // Check if there is a cached version of the unknown account in the local database
    final query =
        db.unknownProfile.select()..where(
          (tbl) =>
              tbl.id.equals(address.encode()) &
              tbl.lastFetched.isBiggerThanValue(DateTime.now().subtract(Duration(hours: 2))),
        );
    final result = await query.getSingleOrNull();
    if (result != null) {
      return UnknownAccount.fromData(result);
    }

    // Get account
    final json = await postAddress(address.server, "/account/get", {"id": address.id});

    // Check if it was successful
    if (!json["success"]) {
      sendLog("couldn't retrieve account ${address.id} on ${address.server} because of: ${json["error"]}");
      return null;
    }

    // Parse the response into an unknown account
    final profile = UnknownAccount(
      address,
      json["name"],
      json["display_name"],
      unpackagePublicKey(json["sg"]),
      unpackagePublicKey(json["pub"]),
    );

    // Add the unknown profile to the database
    await db.unknownProfile.insertOnConflictUpdate(profile.toData(DateTime.now()));
    return profile;
  }
}

class UnknownAccount {
  final LPHAddress id;
  final String name;
  final String displayName;

  final Uint8List signatureKey;
  final Uint8List publicKey;
  DateTime? lastFetch;

  UnknownAccount(this.id, this.name, this.displayName, this.signatureKey, this.publicKey);

  factory UnknownAccount.fromData(UnknownProfileData data) {
    final keys = jsonDecode(fromDbEncrypted(data.keys));
    final account = UnknownAccount(
      LPHAddress.from(data.id),
      fromDbEncrypted(data.name),
      fromDbEncrypted(data.displayName),
      unpackagePublicKey(keys["sg"]),
      unpackagePublicKey(keys["pub"]),
    );
    account.lastFetch = data.lastFetched;
    return account;
  }

  static Future<UnknownAccount> fromFriend(Friend friend) async {
    final keys = await friend.getKeys();
    return UnknownAccount(friend.id, friend.name, friend.displayName.value, keys.signatureKey, keys.publicKey);
  }

  UnknownProfileData toData(DateTime lastFetched) => UnknownProfileData(
    id: id.encode(),
    name: dbEncrypted(name),
    displayName: dbEncrypted(displayName),
    keys: dbEncrypted(jsonEncode({"sg": packagePublicKey(signatureKey), "pub": packagePublicKey(publicKey)})),
    lastFetched: lastFetched,
  );
}
