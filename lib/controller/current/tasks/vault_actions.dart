part of 'vault_sync_task.dart';

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

/// Add a new entry to the vault (payload is encrypted with the public key of the account in the function).
///
/// Returns an error in case there was one.
Future<String?> addToVault(String tag, String payload) async {
  final encryptedPayload = encryptSymmetric(payload, vaultKey);

  final json = await postAuthorizedJSON("/account/vault/add", <String, dynamic>{
    "tag": tag,
    "payload": encryptedPayload,
  });
  if (!json["success"]) {
    return json["error"];
  }

  // Notify the vault sync task about the new entry
  ConnectionController.vaultSyncTask.onUpdateOrInsert(
    tag,
    VaultEntry(
      json["id"],
      tag,
      json["version"],
      StatusController.ownAccountId,
      payload,
      0,
    ),
  );

  return null;
}

/// Update an entry in the vault (payload is encrypted with the public key of the account in the function)
Future<bool> updateVault(String tag, String id, String payload) async {
  final encryptedPayload = encryptSymmetric(payload, vaultKey);

  final json = await postAuthorizedJSON("/account/vault/update", <String, dynamic>{
    "entry": id,
    "payload": encryptedPayload,
  });
  if (!json["success"]) {
    return false;
  }

  // Notify the vault sync task about the new entry
  ConnectionController.vaultSyncTask.onUpdateOrInsert(
    tag,
    VaultEntry(
      id,
      tag,
      json["version"],
      StatusController.ownAccountId,
      payload,
      0,
    ),
  );

  return true;
}
