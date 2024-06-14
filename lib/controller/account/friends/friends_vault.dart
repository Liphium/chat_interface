part of 'friend_controller.dart';

class FriendsVault {
  /// Store friend in vault (returns id of the friend in the vault if successful)
  static Future<String?> store(String data, {errorPopup = false, prefix = "", lastPacket = 0}) async {
    final hash = hashSha(data);
    final payload = encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, data);

    final json = await postAuthorizedJSON("/account/friends/add", <String, dynamic>{
      "hash": hash,
      "payload": payload,
      "receive_date": encryptDate(DateTime.fromMillisecondsSinceEpoch(lastPacket)),
      "send_date": encryptDate(DateTime.fromMillisecondsSinceEpoch(0)),
    });

    if (!json["success"]) {
      if (errorPopup) {
        showErrorPopup("$prefix.${json["error"]}", "$prefix.${json["error"]}");
      }
      return null;
    }

    return json["id"];
  }

  /// Remove friend from vault (returns true if successful)
  static Future<bool> remove(String id, {errorPopup = false}) async {
    final json = await postAuthorizedJSON("/account/friends/remove", <String, dynamic>{
      "id": id,
    });

    return json["success"] as bool;
  }

  /// Encrypt a date with server-side information
  static String encryptDate(DateTime time) {
    return ServerStoredInfo(time.millisecondsSinceEpoch.toString()).transform();
  }

  /// Decrypt a date with server-side information
  static DateTime decryptDate(String text) {
    final info = ServerStoredInfo.untransform(text);
    return DateTime.fromMillisecondsSinceEpoch(int.parse(info.text));
  }

  /// Get the last date a new message was sent to the friend (for replay attack prevention)
  static Future<DateTime?> lastReceiveDate(String id) async {
    final json = await postAuthorizedJSON("/account/friends/get_receive_date", {
      "id": id,
    });

    if (!json["success"]) {
      sendLog("COULDN'T GET THE RECEIVE DATE FOR $id: ${json["error"]}");
      return null;
    }

    return decryptDate(json["date"]);
  }

  /// Set a new receive date (for replay attack prevention)
  static Future<bool> setReceiveDate(String id, DateTime received) async {
    final json = await postAuthorizedJSON("/account/friends/update_receive_date", {
      "id": id,
      "date": encryptDate(received),
    });

    if (!json["success"]) {
      sendLog("COULDN'T SAVE THE NEW RECEIVE DATE ${json["error"]}");
      return false;
    }

    return true;
  }
}

/// Class for storing all keys for a friend
class KeyStorage {
  late String profileKeyPacked;
  String storedActionKey;
  Uint8List publicKey;
  Uint8List signatureKey;

  KeyStorage.empty()
      : publicKey = Uint8List(0),
        signatureKey = Uint8List(0),
        profileKeyPacked = "unbreathable_was_here_but_2024",
        storedActionKey = "unbreathable_was_here";
  KeyStorage(this.publicKey, this.signatureKey, SecureKey profileKey, this.storedActionKey) {
    profileKeyPacked = packageSymmetricKey(profileKey);
    unpackedProfileKey = profileKey;
  }
  KeyStorage.fromJson(Map<String, dynamic> json)
      : publicKey = unpackagePublicKey(json["pub"]),
        profileKeyPacked = json["pf"] ?? "",
        signatureKey = unpackagePublicKey(json["sg"]),
        storedActionKey = json["sa"] ?? "";

  Map<String, dynamic> toJson() {
    return {"pub": packagePublicKey(publicKey), "pf": profileKeyPacked, "sg": packagePublicKey(signatureKey), "sa": storedActionKey};
  }

  // Just so we don't break the API anywhere yk
  SecureKey? unpackedProfileKey;
  SecureKey get profileKey {
    unpackedProfileKey ??= unpackageSymmetricKey(profileKeyPacked);
    return unpackedProfileKey!;
  }
}
