import 'dart:convert';
import 'dart:io';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/pages/status/setup/account/vault_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/web.dart';
import 'package:path/path.dart' as path;

import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:path_provider/path_provider.dart';

class TabletopDecks {
  static String? _cachedPath;

  static void getFilePathForCard(String id) async {
    if (_cachedPath == null) {
      final fileFolder = path.join((await getApplicationCacheDirectory()).path, ".tabletop_cache");
      final dir = Directory(fileFolder);
      _cachedPath = dir.path;
      await dir.create();
    }
  }

  static Future<List<TabletopDeck>?> listDecks() async {
    final json = await postAuthorizedJSON("/account/vault/list", {
      "after": 0,
      "tag": Constants.deckTag,
    });

    if (!json["success"]) {
      return null;
    }

    final decks = <TabletopDeck>[];
    for (var deck in json["entries"]) {
      decks.add(TabletopDeck.decrypt(deck));
    }
    return decks;
  }
}

class TabletopDeck {
  String? vaultId;
  String name;
  final List<AttachmentContainer> cards = [];

  TabletopDeck(this.name, {this.vaultId});

  factory TabletopDeck.decrypt(Map<String, dynamic> json) {
    final entry = VaultEntry.fromJson(json);
    final decrypted = jsonDecode(decryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, asymmetricKeyPair.secretKey, entry.payload));
    final deck = TabletopDeck(
      decrypted['name'],
      vaultId: entry.id,
    );
    for (var card in decrypted['cards']) {
      final container = AttachmentContainer.fromJson(card);
      deck.cards.add(container);
    }
    return deck;
  }

  /// Add the deck to the vault
  Future<bool> save() async {
    final encodedCards = <Map<String, dynamic>>[];
    for (var card in cards) {
      encodedCards.add(card.toJson());
    }
    final payload = jsonEncode({
      "name": name,
      "cards": cards,
    });
    if (vaultId != null) {
      return updateVault(vaultId!, payload);
    }
    final id = await addToVault(Constants.deckTag, payload);
    if (id == null) {
      return false;
    }
    vaultId = id;
    return true;
  }

  Future<bool> delete() async {
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
