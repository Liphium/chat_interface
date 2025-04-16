import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';

class SquareService {
  /// Create a new square.
  ///
  /// Returns an error if there was one.
  static Future<String?> openSquare(List<Friend> friends, String name) async {
    // Create the conversation for the square
    return ConversationService.openConversation(
      model.ConversationType.square,
      friends,
      SquareContainer(name, []),
    );
  }
}
