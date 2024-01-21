import 'dart:io';
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

  static void listDecks() async {
    final json = await postAuthorizedJSON("/account/vault/list", {
      "after": 0,
      "tag": Constants.deckTag,
    });
  }

  static void getDeck() {}
}

class TabletopDeck {
  final String name;
  final List<AttachmentContainer> cards;

  TabletopDeck(this.name, this.cards);

  factory TabletopDeck.fromJson(Map<String, dynamic> json) {
    for (var card in json['cards']) {
      final container = AttachmentContainer.fromJson(card);
    }

    return TabletopDeck(
      json['name'],
      json['cards'],
    );
  }
}
