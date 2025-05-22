import 'dart:convert';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/src/rust/api/encryption.dart';
import 'package:chat_interface/util/encryption/packing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:signals/signals_flutter.dart';

class Square extends Conversation {
  final topicsShown = signal(false);

  Square(
    LPHAddress id,
    String vaultId,
    ConversationToken token,
    SquareContainer container,
    SymmetricKey key,
    int lastVersion,
    int updatedAt,
    ConversationReads reads,
  ) : super(id, vaultId, model.ConversationType.square, token, container, key, lastVersion, updatedAt, reads);

  @override
  Square.fromJson(Map<String, dynamic> json, String vaultId)
    : this(
        LPHAddress.from(json["id"]),
        vaultId,
        ConversationToken.fromJson(json["token"]),
        SquareContainer.fromJson(json["data"]),
        json["key"],
        0, // Just ignore it for now
        json["update"] ?? DateTime.now().millisecondsSinceEpoch,
        ConversationReads.fromContainer(""),
      );

  static Future<Square?> fromData(ConversationData data) async {
    final results = await Future.wait([
      fromDbEncrypted(data.vaultId),
      fromDbEncrypted(data.token),
      fromDbEncrypted(data.data),
      fromDbEncrypted(data.key),
      fromDbEncrypted(data.reads),
    ]);
    if (results.any((a) => a == null)) {
      return null;
    }
    final key = await unpackageSymmetricKey(results[3]!);
    if (key == null) {
      return null;
    }

    return Square(
      LPHAddress.from(data.id),
      results[0]!,
      ConversationToken.fromJson(jsonDecode(results[1]!)),
      SquareContainer.fromJson(jsonDecode(results[2]!)),
      key,
      data.lastVersion.toInt(),
      data.updatedAt.toInt(),
      ConversationReads.fromContainer(results[4]!),
    );
  }
}
