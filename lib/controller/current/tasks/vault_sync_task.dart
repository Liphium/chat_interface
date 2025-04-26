import 'dart:async';

import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/square/shared_space_controller.dart';
import 'package:chat_interface/services/chat/library_manager.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/chat/vault_versioning_service.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'vault_actions.dart';

class VaultSyncTask extends SynchronizationTask {
  VaultSyncTask() : super("loading.vault");

  // All vault targets (everything that needs sync from the server vault)
  final List<VaultTarget> targets = [ConversationService(), LibraryManager()];

  @override
  Future<String?> init() async {
    // Initialize all vault targets
    for (var target in targets) {
      await target.init();
    }
    return null;
  }

  @override
  Future<String?> refresh() async {
    // Get the latest versions of all the targets
    Map<String, int> versionMap = {};
    for (var target in targets) {
      versionMap[target.tag] = await VaultVersioningService.retrieveVersion(
        VaultVersioningService.vaultTypeGeneral,
        target.tag,
      );
    }

    // Synchronize using the endpoint from the server
    final json = await postAuthorizedJSON("/account/vault/sync", {"tags": versionMap});
    if (!json["success"]) {
      return json["error"];
    }

    // Parse all of the entries
    final (deleted, newEntries, newVersions) = await sodiumLib.runIsolated((sodium, keys, pairs) {
      // Sort the entries into deleted ones and new ones per tag
      var deleted = <String, List<String>>{};
      var newEntries = <String, List<VaultEntry>>{};
      for (var unparsedEntry in json["entries"]) {
        final entry = VaultEntry.fromJson(unparsedEntry);

        // Increment the version of the tag in case increased
        if (entry.version > versionMap[entry.tag]!) {
          versionMap[entry.tag] = entry.version;
        }

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
          if (newEntries[entry.tag] == null) {
            newEntries[entry.tag] = [entry];
          } else {
            newEntries[entry.tag]!.add(entry);
          }
        }
      }

      // Return both lists to the outside
      return (deleted, newEntries, versionMap);
    }, secureKeys: [vaultKey]);

    // Save all the new versions
    for (var target in targets) {
      unawaited(
        VaultVersioningService.storeOrUpdateVersion(
          VaultVersioningService.vaultTypeGeneral,
          target.tag,
          newVersions[target.tag]!,
        ),
      );
    }

    // Notify the vault targets about the changes
    for (var target in targets) {
      target.processEntries(deleted[target.tag] ?? [], newEntries[target.tag] ?? []);
    }

    return null;
  }

  /// Called by vault_actions when a new entry is added or updated
  void onUpdateOrInsert(String tag, VaultEntry entry, int version) {
    final target = targets.firstWhereOrNull((target) => target.tag == tag);
    if (target == null) {
      return;
    }

    // Let the target process the new entry
    target.processEntries([], [entry]);
    unawaited(
      VaultVersioningService.storeOrUpdateVersion(VaultVersioningService.vaultTypeGeneral, target.tag, version),
    );
  }

  /// Called by vault_actions when an entry is deleted
  void onDeletion(String tag, String id, int version) {
    final target = targets.firstWhereOrNull((target) => target.tag == tag);
    if (target == null) {
      return;
    }

    // Let the target process the deletion
    target.processEntries([id], []);
    unawaited(
      VaultVersioningService.storeOrUpdateVersion(VaultVersioningService.vaultTypeGeneral, target.tag, version),
    );
  }

  @override
  void onRestart() {
    SharedSpaceController.clearAll();
  }
}

abstract class VaultTarget {
  final String tag;

  VaultTarget(this.tag);

  /// Called on intialization by the vault sync task
  Future<void> init() async {}

  /// Called when the vault is refreshed with the new entries and the deleted ones
  void processEntries(List<String> deleted, List<VaultEntry> newEntries);
}

class VaultEntry {
  final String id;
  final String tag;
  final String account;
  final int version;
  String payload;
  final int updatedAt;
  bool error = false;

  VaultEntry(this.id, this.tag, this.version, this.account, this.payload, this.updatedAt);
  VaultEntry.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      tag = json["tag"],
      version = json["version"],
      account = json["account"],
      payload = json["payload"],
      updatedAt = json["updated_at"];

  String decryptedPayload([SecureKey? key, Sodium? sodium]) => decryptSymmetric(payload, key ?? vaultKey, sodium);
}
