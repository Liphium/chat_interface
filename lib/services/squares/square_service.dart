import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/web.dart';
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

  /// Create a new Space and add it to a square.
  ///
  /// Returns an error if there was one.
  static Future<String?> createSharedSpace(Square square, String name, {String underlyingId = "-"}) async {
    // Create a new Space (if not connected already)
    if (!SpaceController.connected.peek()) {
      // Create a new Space
      final error = await SpaceController.createSpace(false, openPage: false);
      if (error != null) {
        return error;
      }
    }
    final container = SpaceController.getContainer();

    // Add the Space to the square as a shared space
    final json = await postNodeJSON("/conversations/shared_spaces/add", {
      "token": square.token.toMap(square.id),
      "data": {
        "server": container.node,
        "id": container.roomId,
        "underlying_id": underlyingId,
        "name": encryptSymmetric(name, square.key),
        "container": encryptSymmetric(container.toInviteJson(), square.key),
      },
    });
    if (!json["success"]) {
      return json["error"];
    }
    if (json["exists"]) {
      return "squares.space.already_added".tr;
    }

    return null;
  }
}
