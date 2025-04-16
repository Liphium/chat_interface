import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/util/web.dart';

class Square extends Conversation {
  Square(
    LPHAddress id,
    String vaultId,
    ConversationToken token,
    SquareContainer container,
    String packedKey,
    int lastVersion,
    int updatedAt,
  ) : super(
        id,
        vaultId,
        model.ConversationType.square,
        token,
        container,
        packedKey,
        lastVersion,
        updatedAt,
      );

  @override
  factory Square.copyWithoutKey(Square square) {
    final copy = Square(
      square.id,
      square.vaultId,
      square.token,
      square.container as SquareContainer,
      "",
      square.updatedAt.value,
      square.lastVersion,
    );

    // Copy all the members
    copy.members.addAll(square.members);

    return copy;
  }
}
