import 'dart:convert';

import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/database/trusted_links.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/util/encryption/packing.dart';
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
        signatureKeyPair.verifyingKey,
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
    final verifyKey = await unpackageVerifyingKey(json["sg"]);
    final pub = await unpackagePublicKey(json["pub"]);
    if (verifyKey == null || pub == null) {
      sendLog("couldn't unpack keys from the server");
      return null;
    }
    final profile = UnknownAccount(
      LPHAddress(basePath, json["id"]),
      json["name"],
      json["display_name"],
      verifyKey,
      pub,
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
        signatureKeyPair.verifyingKey,
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
    final verifyKey = await unpackageVerifyingKey(json["sg"]);
    final pub = await unpackagePublicKey(json["pub"]);
    if (verifyKey == null || pub == null) {
      sendLog("couldn't unpack keys from the server");
      return null;
    }
    final profile = UnknownAccount(address, json["name"], json["display_name"], verifyKey, pub);

    // Add the unknown profile to the database
    await db.unknownProfile.insertOnConflictUpdate(await profile.toData(DateTime.now()));
    return profile;
  }
}

class UnknownAccount {
  final LPHAddress id;
  final String name;
  final String displayName;

  final VerifyingKey verifyKey;
  final PublicKey publicKey;
  DateTime? lastFetch;

  UnknownAccount(this.id, this.name, this.displayName, this.verifyKey, this.publicKey);

  static Future<UnknownAccount?> fromData(UnknownProfileData data) async {
    // Decrypt the key json
    final keys = await fromDbEncrypted(data.keys);
    if (keys == null) {
      return null;
    }
    final keyStore = jsonDecode(keys);

    // Decrypt the rest from the database
    final name = await fromDbEncrypted(data.name);
    final displayName = await fromDbEncrypted(data.displayName);
    final verifyKey = await unpackageVerifyingKey(keyStore["sg"]);
    final pub = await unpackagePublicKey(keyStore["pub"]);
    if (name == null || displayName == null || verifyKey == null || pub == null) {
      return null;
    }

    // Create the account and return
    final account = UnknownAccount(LPHAddress.from(data.id), name, displayName, verifyKey, pub);
    account.lastFetch = data.lastFetched;
    return account;
  }

  static Future<UnknownAccount> fromFriend(Friend friend) async {
    final keys = await friend.getKeys();
    return UnknownAccount(friend.id, friend.name, friend.displayName.value, keys.verifyKey, keys.publicKey);
  }

  Future<UnknownProfileData> toData(DateTime lastFetched) async => UnknownProfileData(
    id: id.encode(),
    name: await dbEncrypted(name),
    displayName: await dbEncrypted(displayName),
    keys: await dbEncrypted(
      jsonEncode({"sg": await packageVerifyingKey(verifyKey), "pub": await packagePublicKey(publicKey)}),
    ),
    lastFetched: lastFetched,
  );
}
