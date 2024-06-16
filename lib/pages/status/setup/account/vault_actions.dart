part of 'vault_setup.dart';

/// Remove an entry from the vault (returns null if successful (error otherwise))
Future<String?> removeFromVault(String id) async {
  final json = await postAuthorizedJSON("/account/vault/remove", <String, dynamic>{
    "id": id,
  });
  if (!json["success"]) {
    return json["error"];
  }

  return null;
}

/// Add a new entry to the vault (payload is encrypted with the public key of the account in the function)
Future<String?> addToVault(String tag, String payload) async {
  final encryptedPayload = encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, payload);

  final json = await postAuthorizedJSON("/account/vault/add", <String, dynamic>{
    "tag": tag,
    "payload": encryptedPayload,
  });
  if (!json["success"]) {
    return null;
  }

  return json["id"];
}

/// Update an entry in the vault (payload is encrypted with the public key of the account in the function)
Future<bool> updateVault(String id, String payload) async {
  final encryptedPayload = encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, payload);

  final json = await postAuthorizedJSON("/account/vault/update", <String, dynamic>{
    "entry": id,
    "payload": encryptedPayload,
  });
  if (!json["success"]) {
    return false;
  }

  return true;
}
