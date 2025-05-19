import 'dart:convert';
import 'package:chat_interface/controller/current/tasks/vault_sync_task.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/web.dart';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:signals/signals.dart';

class TabletopDecks {
  static Future<List<TabletopDeck>?> listDecks() async {
    final json = await postAuthorizedJSON("/account/vault/list", {"after": 0, "tag": Constants.vaultDeckTag});

    if (!json["success"]) {
      return null;
    }

    final decks = <TabletopDeck>[];
    for (var deck in json["entries"]) {
      decks.add(TabletopDeck.decrypt(StorageType.permanent, deck));
    }
    return decks;
  }
}

class TabletopDeck {
  String? vaultId;
  String name;
  List<dynamic> encodedCards = [];
  final cards = signal(<AttachmentContainer>[]);
  final amounts = signal(<String, int>{}); // Map of card id to amount

  TabletopDeck(this.name, {this.vaultId});

  factory TabletopDeck.decrypt(StorageType usecase, Map<String, dynamic> json) {
    final entry = VaultEntry.fromJson(json);
    final decrypted = jsonDecode(entry.decryptedPayload());
    final deck = TabletopDeck(decrypted['name'], vaultId: entry.id);
    if (decrypted['cards'] == null) {
      return deck;
    }
    deck.encodedCards = decrypted['cards'];
    deck.loadCards(usecase);
    return deck;
  }

  /// Add the deck to the vault
  Future<bool> save() async {
    final encodedCards = <Map<String, dynamic>>[];
    for (var card in cards.peek()) {
      final json = card.toJson();
      json["amount"] = amounts.peek()[card.id] ?? 1;
      encodedCards.add(json);
    }
    final payload = jsonEncode({"name": name, "cards": encodedCards});
    if (vaultId != null) {
      return updateVault(Constants.vaultDeckTag, vaultId!, payload);
    }
    final (_, id) = await addToVault(Constants.vaultDeckTag, payload);
    if (id == null) {
      return false;
    }
    vaultId = id;
    return true;
  }

  /// usecase is the type of storage to use for the cards (for downloaded ones it should be "cache" for example)
  Future<void> loadCards(StorageType usecase) async {
    bool removed = false;
    for (var card in encodedCards) {
      final type = await AttachmentController.checkLocations(
        card['i'],
        usecase,
        types: [StorageType.permanent, StorageType.cache],
      );
      final container = AttachmentController.fromJson(type, card);
      amounts.value[container.id] = card['a'] ?? 1;
      final result = await AttachmentController.downloadAttachment(container);
      if (!result || container.error.value) {
        removed = true;
        continue;
      }
      cards.value.add(container);
    }

    // Save the deck in case cards have been removed because they don't exist anymore
    if (removed) {
      await save();
    }
    encodedCards.clear();
  }

  Future<bool> delete() async {
    // Delete all cards
    for (var card in cards.peek()) {
      await AttachmentController.deleteFile(card);
    }

    if (vaultId == null) {
      return false;
    }
    final error = await removeFromVault(vaultId!);
    if (error != null) {
      return false;
    }
    return true;
  }
}
