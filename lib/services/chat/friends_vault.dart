part of '../../controller/account/friend_controller.dart';

class FriendsVault {
  /// Store a received request in the vault.
  ///
  /// Returns an error if there was one.
  static Future<String?> storeReceivedRequest(Request request) async {
    // Store the request in the vault
    final (error, entry) = await _store(request.toStoredPayload(false));
    if (error != null) {
      return error;
    }

    // Call the related vault update event
    request.vaultId = entry!.$1;
    await updateFromVaultUpdate(FriendVaultUpdate(entry.$2, [], [], [request], [], []));
    return null;
  }

  /// Store a sent request in the vault.
  ///
  /// Returns an error if there was one.
  static Future<String?> storeSentRequest(Request request) async {
    // Store the request in the vault
    final (error, entry) = await _store(request.toStoredPayload(true));
    if (error != null) {
      return error;
    }

    // Call the related vault update event
    request.vaultId = entry!.$1;
    await updateFromVaultUpdate(FriendVaultUpdate(entry.$2, [], [], [], [request], []));
    return null;
  }

  /// Helper method for storing things in the friends vault.
  ///
  /// The first element is an error if there was one.
  /// The second element is a tuple of vault id and version in case successful.
  static Future<(String?, (String, int)?)> _store(String data) async {
    // Encrypt the friend for the vault
    final payload = await encryptSymmetricContainer(
      key: vaultKey,
      signingKey: signatureKeyPair.signingKey,
      message: packToBytes(data),
    );
    if (payload == null) {
      return ("encryption.error".tr, null);
    }

    // Add the friend to the vault
    final json = await postAuthorizedJSON("/account/friends/add", <String, dynamic>{
      "payload": base64Encode(payload),
      "receive_date": encryptDate(DateTime.fromMillisecondsSinceEpoch(0)),
    });

    // Check if there was an error
    if (!json["success"]) {
      return (json["error"] as String, null);
    }
    return (null, (json["id"] as String, (json["version"] as num).toInt()));
  }

  /// Update a friend in the vault.
  ///
  /// Returns an error if there was one.
  static Future<String?> updateFriend(Friend friend) async {
    // Store the request in the vault
    final (error, version) = await _update(friend.vaultId, await friend.toStoredPayload());
    if (error != null) {
      return error;
    }

    // Call the related vault update event
    await updateFromVaultUpdate(FriendVaultUpdate(version!, [], [friend.vaultId], [], [], [friend]));
    return null;
  }

  /// Helper method for updating things in the friends vault.
  ///
  /// The first element is an error if there was one.
  /// The second element is the new version in case successsful.
  static Future<(String?, int?)> _update(String id, String data) async {
    // Encrypt the friend for the vault
    final payload = await encryptSymmetricContainer(
      key: vaultKey,
      signingKey: signatureKeyPair.signingKey,
      message: packToBytes(data),
    );
    if (payload == null) {
      return ("encryption.error".tr, null);
    }

    // Add the friend to the vault
    final json = await postAuthorizedJSON("/account/friends/update", <String, dynamic>{
      "entry": id,
      "payload": base64Encode(payload),
    });

    // Check if there was an error
    if (!json["success"]) {
      return (json["error"] as String, null);
    }
    return (null, (json["version"] as num).toInt());
  }

  /// Remove friend from vault.
  ///
  /// Returns an error if there was one.
  static Future<String?> remove(String vaultId) async {
    // Remove the friend from the server vault
    final json = await postAuthorizedJSON("/account/friends/remove", <String, dynamic>{"id": vaultId});
    if (!json["success"]) {
      return json["error"];
    }

    // Update the local vault
    await updateFromVaultUpdate(FriendVaultUpdate(json["version"], [vaultId], [], [], [], []));
    return null;
  }

  /// Encrypt a date with server-side information
  static Future<String?> encryptDate(DateTime time) async {
    return await ServerStoredInfo(time.millisecondsSinceEpoch.toString()).transform();
  }

  /// Decrypt a date with server-side information
  static Future<DateTime?> decryptDate(String text) async {
    final info = await ServerStoredInfo.untransform(text);
    if (info.error) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(info.text));
  }

  /// Get the last date a new message was sent to the friend (for replay attack prevention)
  static Future<DateTime?> lastReceiveDate(String id) async {
    final json = await postAuthorizedJSON("/account/friends/get_receive_date", {"id": id});

    if (!json["success"]) {
      sendLog("COULDN'T GET THE RECEIVE DATE FOR $id: ${json["error"]}");
      return null;
    }

    try {
      return decryptDate(json["date"]);
    } catch (e) {
      return null;
    }
  }

  /// Set a new receive date (for replay attack prevention)
  static Future<bool> setReceiveDate(String id, DateTime received) async {
    final date = await encryptDate(received);
    if (date == null) {
      return false;
    }
    final json = await postAuthorizedJSON("/account/friends/update_receive_date", {"id": id, "date": date});

    if (!json["success"]) {
      sendLog("COULDN'T SAVE THE NEW RECEIVE DATE ${json["error"]}");
      return false;
    }

    return true;
  }

  /// A global boolean that tells you whether the friends vault is currently refreshing or not
  static final friendsVaultRefreshing = signal(false);

  /// Refresh all friends and load them from the vault (also removes what's not on the server)
  static Future<String?> refreshFriendsVault() async {
    if (friendsVaultRefreshing.value) {
      sendLog("COLLISION: Friends vault is already refreshing, this should be something worth looking into");
      return null;
    }

    // Get the latest version
    final version = await VaultVersioningService.retrieveVersion(VaultVersioningService.vaultTypeFriend, "");

    friendsVaultRefreshing.value = true;
    // Load friends from vault
    final json = await postAuthorizedJSON("/account/friends/sync", <String, dynamic>{"version": version});
    if (!json["success"]) {
      friendsVaultRefreshing.value = false;
      return "friends.error".tr;
    }

    // Parse the JSON (in different isolate)
    final res = await _parseFriends(version, json);

    // Update the local vault
    await updateFromVaultUpdate(res);

    friendsVaultRefreshing.value = false;
    return null;
  }

  /// Parse a response from the server vault sync to a friend vault update
  static Future<FriendVaultUpdate> _parseFriends(int currentVersion, Map<String, dynamic> json) async {
    final deleted = <String>[];
    final friendVaultIds = <String>[];
    final friends = <Friend>[];
    final requests = <Request>[];
    final requestsSent = <Request>[];
    for (var friend in json["friends"]) {
      // Set the new version
      if (friend["version"] > currentVersion) {
        currentVersion = friend["version"];
      }

      // Add to the list of deleted ids when it was deleted
      if (friend["deleted"]) {
        deleted.add(friend["id"]);
        continue;
      }

      // Decrypt the request
      final unpacked = decodeFromBase64(friend["friend"]);
      if (unpacked == null) {
        sendLog("ERROR: Couldn't unpack friend");
        continue;
      }
      final decrypted = await decryptSymmetricContainer(
        ciphertext: unpacked,
        key: vaultKey,
        verifyingKey: signatureKeyPair.verifyingKey,
      );
      if (decrypted == null) {
        sendLog("ERROR: Couldn't decrypt friend from the server");
        continue;
      }
      final friendUnpacked = unpackFromBytes(decrypted);
      if (friendUnpacked == null) {
        sendLog("ERROR: Couldn't unpack friend (internal)");
        continue;
      }

      final data = jsonDecode(friendUnpacked);
      if (data["rq"]) {
        if (data["self"]) {
          final rq = Request.fromStoredPayload(friend["id"], friend["updated_at"], data);
          requestsSent.add(rq);
        } else {
          final rq = Request.fromStoredPayload(friend["id"], friend["updated_at"], data);
          requests.add(rq);
        }
      } else {
        final fr = Friend.fromStoredPayload(friend["id"], friend["updated_at"], data);
        friends.add(fr);
        friendVaultIds.add(friend["id"]);
      }
    }

    return FriendVaultUpdate(currentVersion, deleted, friendVaultIds, requests, requestsSent, friends);
  }

  /// Update the local vault using a server friends vault update
  static Future<void> updateFromVaultUpdate(FriendVaultUpdate update) async {
    // Change the version to the one in the update
    await VaultVersioningService.storeOrUpdateVersion(VaultVersioningService.vaultTypeFriend, "", update.newVersion);

    // Update the requests
    for (var request in update.requests) {
      if (RequestController.requests[request.id] == null) {
        RequestsService.onVaultUpdate(request);
      }
    }

    // Remove all requests and also the ones that aren't requests anymore (a friend could've been upgraded)
    if (update.deleted.isNotEmpty || update.friendVaultIds.isNotEmpty) {
      RequestController.requests.removeWhere((item, rq) {
        if (update.deleted.contains(rq.vaultId) || update.friendVaultIds.contains(rq.vaultId)) {
          unawaited(db.request.deleteWhere((t) => t.id.equals(rq.id.encode())));
          return true;
        }
        return false;
      });
    }

    for (var request in update.requestsSent) {
      if (RequestController.requestsSent[request.id] == null) {
        RequestsService.onVaultUpdateSent(request);
      }
    }

    // Remove all requests and also the ones that aren't requests anymore (a friend could've been upgraded)
    if (update.deleted.isNotEmpty || update.friendVaultIds.isNotEmpty) {
      RequestController.requestsSent.removeWhere((item, rq) {
        if (update.deleted.contains(rq.vaultId) || update.friendVaultIds.contains(rq.vaultId)) {
          unawaited(db.request.deleteWhere((t) => t.id.equals(rq.id.encode())));
          return true;
        }
        return false;
      });
    }

    // Push friends
    for (var friend in update.friends) {
      if (FriendController.friends[friend.id] == null) {
        await FriendsService.onVaultUpdate(friend);
      }
    }
    if (update.deleted.isNotEmpty) {
      FriendController.friends.removeWhere((id, fr) {
        if (update.deleted.contains(fr.vaultId) && id != StatusController.ownAddress) {
          unawaited(db.friend.deleteWhere((t) => t.id.equals(fr.id.encode())));
          return true;
        }
        return false;
      });
    }
  }
}

class FriendVaultUpdate {
  final int newVersion;

  final List<String> deleted;
  final List<String> friendVaultIds;

  final List<Request> requests;
  final List<Request> requestsSent;
  final List<Friend> friends;

  FriendVaultUpdate(this.newVersion, this.deleted, this.friendVaultIds, this.requests, this.requestsSent, this.friends);
}

/// Class for storing all keys for a friend
class KeyStorage {
  SymmetricKey profileKey;
  String storedActionKey;
  PublicKey publicKey;
  VerifyingKey verifyKey;

  KeyStorage.empty()
    : publicKey = PublicKey(id: 0),
      verifyKey = VerifyingKey(id: 0),
      profileKey = SymmetricKey(id: 0),
      storedActionKey = "unbreathable_was_here";
  KeyStorage(this.publicKey, this.verifyKey, this.profileKey, this.storedActionKey);

  static Future<KeyStorage?> fromJson(Map<String, dynamic> json) async {
    final pub = await unpackagePublicKey(json["pub"]);
    final profileKey = await unpackageSymmetricKey(json["pf"]);
    final verifyKey = await unpackageVerifyingKey(json["ve"]);
    if (pub == null || profileKey == null || verifyKey == null) {
      return null;
    }

    return KeyStorage(pub, verifyKey, profileKey, json["sa"]);
  }

  Future<Map<String, dynamic>> toJson() async {
    final pub = await packagePublicKey(publicKey);
    final prof = await packageSymmetricKey(profileKey);
    final verify = await packageVerifyingKey(verifyKey);

    return {"pub": pub, "pf": prof, "ve": verify, "sa": storedActionKey};
  }
}
