import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:get/get_utils/get_utils.dart';

class SquareService {
  /// Create a new square.
  ///
  /// Returns an error if there was one.
  static Future<String?> openSquare(List<Friend> friends, String name) async {
    // Create the conversation for the square
    return ConversationService.openConversation(model.ConversationType.square, friends, SquareContainer(name, []));
  }

  /// Add a topic to a square.
  ///
  /// Returns an error if there was one.
  static Future<String?> createTopic(Square square, String name) async {
    final current = square.container as SquareContainer;

    // Make sure there aren't too many topics
    if (current.topics.length >= 5) {
      return "squares.topics.too_many".tr;
    }

    // Generate a new container for the square
    final newContainer = SquareContainer(current.name, [...current.topics]);
    String topicId = randomString(8);
    while (newContainer.topics.any((t) => t.id == topicId)) {
      topicId = randomString(8);
    }
    newContainer.topics.add(Topic(topicId, name));

    // Try to change the data of the square to the new container
    return await ConversationService.setData(square, newContainer);
  }

  /// Cryptographically‐secure random generator
  static final _rnd = Random.secure();

  /// Generate a random string of given length using a-z, A-Z, 1-9 (requirements for topic id)
  static String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    return List.generate(length, (_) => chars[_rnd.nextInt(chars.length)]).join();
  }
}
