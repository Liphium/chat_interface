part of 'vault_sync_task.dart';

/// Remove an entry from the vault (returns null if successful (error otherwise))
Future<String?> removeFromVault(String id) async {
  final json = await postAuthorizedJSON("/account/vault/remove", <String, dynamic>{"id": id});
  if (!json["success"]) {
    return json["error"];
  }

  // Notify the vault sync task about the deletion of the entry
  ConnectionController.vaultSyncTask.onDeletion(json["tag"], id, json["version"]);

  return null;
}

/// Add a new entry to the vault (payload is encrypted with the public key of the account in the function).
///
/// The first element is an error in case there was one.
/// The second element is the vault id if successfull.
Future<(String?, String?)> addToVault(String tag, String payload) async {
  final encryptedPayload = encryptSymmetric(payload, vaultKey);

  final json = await postAuthorizedJSON("/account/vault/add", <String, dynamic>{
    "tag": tag,
    "payload": encryptedPayload,
  });
  if (!json["success"]) {
    return (json["error"] as String, null);
  }

  // Notify the vault sync task about the new entry
  ConnectionController.vaultSyncTask.onUpdateOrInsert(
    tag,
    VaultEntry(json["id"], tag, json["version"], StatusController.ownAccountId, payload, 0),
    json["version"],
  );

  return (null, json["id"] as String);
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
    VaultEntry(id, tag, json["version"], StatusController.ownAccountId, payload, 0),
    json["version"],
  );

  return true;
}
