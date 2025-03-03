import 'package:chat_interface/services/chat/conversation_vault_target.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/web.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'vault_actions.dart';

class VaultSyncTask extends SynchronizationTask {
  VaultSyncTask() : super("loading.vault", const Duration(seconds: 30));

  // All vault targets (everything that needs sync from the server vault)
  final List<VaultTarget> targets = [
    ConversationVaultTarget(),
  ];

  @override
  Future<String?> init() async {
    // Initialize all vault targets
    for (var target in targets) {
      target.init();
    }
    return null;
  }

  @override
  Future<String?> refresh() async {
    // Get the latest versions of all the targets
    Map<String, int> versionMap = {};
    for (var target in targets) {
      versionMap[target.tag] = await target.getLatestVersion();
    }

    // Synchronize using the endpoint from the server
    final json = await postAuthorizedJSON("/account/vault/sync", {
      "tags": versionMap,
    });
    if (!json["success"]) {
      return json["error"];
    }

    // Parse all of the entries
    final (deleted, newEntries) = await sodiumLib.runIsolated((sodium, keys, pairs) {
      // Sort the entries into deleted ones and new ones per tag
      var deleted = <String, List<String>>{};
      var newEntries = <String, List<VaultEntry>>{};
      for (var unparsedEntry in json["entries"]) {
        final entry = VaultEntry.fromJson(unparsedEntry);
        if (unparsedEntry["deleted"] == true) {
          // Create a new deleted list or add if list already there
          if (deleted[entry.tag] == null) {
            deleted[entry.tag] = [entry.id];
          } else {
            deleted[entry.tag]!.add(entry.id);
          }
        } else {
          // Decrypt payload and add to list of new entries
          entry.payload = decryptSymmetric(entry.payload, keys[0], sodium);
          if (deleted[entry.tag] == null) {
            newEntries[entry.tag] = [entry];
          } else {
            newEntries[entry.tag]!.add(entry);
          }
        }
      }

      // Return both lists to the outside
      return (deleted, newEntries);
    }, secureKeys: [vaultKey]);

    // Notify the vault targets about the changes
    for (var target in targets) {
      target.processEntries(deleted[target.tag] ?? [], newEntries[target.tag] ?? []);
    }

    return null;
  }

  @override
  void onRestart() {}
}

abstract class VaultTarget {
  final String tag;

  VaultTarget(this.tag);

  /// Called on intialization by the vault sync task
  void init() {}

  /// Get the latest version of the vault tag
  Future<int> getLatestVersion();

  /// Called when the vault is refreshed with the new entries and the deleted ones
  void processEntries(List<String> deleted, List<VaultEntry> newEntries);
}

class VaultEntry {
  final String id;
  final String tag;
  final String account;
  String payload;
  final int updatedAt;
  bool error = false;

  VaultEntry(this.id, this.tag, this.account, this.payload, this.updatedAt);
  VaultEntry.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        tag = json["tag"],
        account = json["account"],
        payload = json["payload"],
        updatedAt = json["updated_at"];

  String decryptedPayload([SecureKey? key, Sodium? sodium]) => decryptSymmetric(payload, key ?? vaultKey, sodium);
}
