import 'dart:convert';

import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/util/web.dart';
import 'package:signals/signals_flutter.dart';

class Square extends Conversation {
  final topicsShown = signal(false);

  Square(
    LPHAddress id,
    String vaultId,
    ConversationToken token,
    SquareContainer container,
    String packedKey,
    int lastVersion,
    int updatedAt,
  ) : super(id, vaultId, model.ConversationType.square, token, container, packedKey, lastVersion, updatedAt);

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
      );

  @override
  Square.fromData(ConversationData data)
    : this(
        LPHAddress.from(data.id),
        fromDbEncrypted(data.vaultId),
        ConversationToken.fromJson(jsonDecode(fromDbEncrypted(data.token))),
        SquareContainer.fromJson(jsonDecode(fromDbEncrypted(data.data))),
        fromDbEncrypted(data.key),
        data.lastVersion.toInt(),
        data.updatedAt.toInt(),
      );

  @override
  factory Square.copyWithoutKey(Square square) {
    final copy = Square(
      square.id,
      square.vaultId,
      square.token,
      square.container as SquareContainer,
      "",
      square.lastVersion,
      square.updatedAt,
    );

    // Copy all the members
    copy.members.addAll(square.members);

    return copy;
  }
}
