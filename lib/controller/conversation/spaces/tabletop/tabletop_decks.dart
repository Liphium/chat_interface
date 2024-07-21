import 'dart:convert';
import 'package:chat_interface/pages/status/setup/account/vault_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/web.dart';

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:get/get.dart';

class TabletopDecks {
  static Future<List<TabletopDeck>?> listDecks() async {
    final json = await postAuthorizedJSON("/account/vault/list", {
      "after": 0,
      "tag": Constants.vaultDeckTag,
    });

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
  final cards = <AttachmentContainer>[].obs;
  final amounts = <String, int>{}.obs; // Map of card id to amount

  TabletopDeck(this.name, {this.vaultId});

  factory TabletopDeck.decrypt(StorageType usecase, Map<String, dynamic> json) {
    final entry = VaultEntry.fromJson(json);
    final decrypted = jsonDecode(entry.decryptedPayload());
    final deck = TabletopDeck(
      decrypted['name'],
      vaultId: entry.id,
    );
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
    for (var card in cards) {
      final json = card.toJson();
      json["amount"] = amounts[card.id] ?? 1;
      encodedCards.add(json);
    }
    final payload = jsonEncode({
      "name": name,
      "cards": encodedCards,
    });
    if (vaultId != null) {
      return updateVault(vaultId!, payload);
    }
    final id = await addToVault(Constants.vaultDeckTag, payload);
    if (id == null) {
      return false;
    }
    vaultId = id;
    return true;
  }

  /// usecase is the type of storage to use for the cards (for downloaded ones it should be "cache" for example)
  void loadCards(StorageType usecase) async {
    final controller = Get.find<AttachmentController>();
    for (var card in encodedCards) {
      final type = await AttachmentController.checkLocations(card['id'], usecase, types: [StorageType.permanent, StorageType.cache]);
      final container = AttachmentContainer.fromJson(type, card);
      amounts[container.id] = card['amount'] ?? 1;
      await controller.downloadAttachment(container);
      cards.add(container);
    }
    encodedCards.clear();
  }

  Future<bool> delete() async {
    // Delete all cards
    final controller = Get.find<AttachmentController>();
    for (var card in cards) {
      await controller.deleteFile(card);
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
