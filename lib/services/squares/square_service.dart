import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/controller/spaces/space_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/services/squares/square_shared_space.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get_utils/get_utils.dart';

class SquareService {
  /// Create a new square.
  ///
  /// Returns an error if there was one.
  static Future<String?> openSquare(List<Friend> friends, String name) async {
    // Create the conversation for the square
    return ConversationService.openConversation(model.ConversationType.square, friends, SquareContainer(name, [], []));
  }

  /// Add a topic to a square.
  ///
  /// Returns an error if there was one.
  static Future<String?> createTopic(Square square, String name) async {
    final current = square.container as SquareContainer;

    // Generate a new container for the square
    final newContainer = SquareContainer(current.name, [...current.topics], [...current.spaces]);
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
  static Future<String?> createSharedSpace(
    Square square,
    String name, {
    String underlyingId = "-",
    bool rejoin = false,
  }) async {
    // Create a new Space (if not connected already)
    if (!SpaceController.connected.peek() || rejoin) {
      // Leave in case rejoin is true
      if (rejoin && SpaceController.connected.peek()) {
        await SpaceController.leaveSpace();
      }

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

  /// Pin a new shared space in a Square.
  ///
  /// Returns an error if there was one.
  static Future<String?> pinSharedSpace(Square square, SharedSpace space) async {
    // Add to the square as a new pinned space
    final pinnedSpace = newPinnedSharedSpace(square, space.name);
    final error = await pinPinnedSpace(square, pinnedSpace);
    if (error != null) {
      return error;
    }

    // Change to pinned on the chat server
    return await changePinnedStatus(square, space.id, pinnedSpace.id);
  }

  /// Pin a pinned shared space in a Square.
  ///
  /// Returns an error if there was one.
  static Future<String?> pinPinnedSpace(Square square, PinnedSharedSpace space) async {
    final current = square.container as SquareContainer;

    // Generate a new container for the square
    final newContainer = SquareContainer.copy(current);
    newContainer.spaces.add(space);

    // Set the new data
    return await ConversationService.setData(square, newContainer);
  }

  /// Generate a new pinned shared space for a square.
  static PinnedSharedSpace newPinnedSharedSpace(Square square, String name) {
    final container = square.container as SquareContainer;

    // Generate a new id for the pinned shared space
    String sharedSpaceId = randomString(8);
    while (container.spaces.any((s) => s.id == sharedSpaceId)) {
      sharedSpaceId = randomString(8);
    }

    return PinnedSharedSpace(sharedSpaceId, name);
  }

  /// Unpin a shared space in a Square.
  /// Set [space] in case currently shared.
  ///
  /// Returns an error if there was one.
  static Future<String?> unpinSharedSpace(Square square, String id, {SharedSpace? space}) async {
    // Generate a new container for the square
    final newContainer = SquareContainer.copy(square.container as SquareContainer);
    newContainer.spaces.removeWhere((s) => s.id == id);

    // Set the new data
    var error = await ConversationService.setData(square, newContainer);
    if (error != null) {
      return error;
    }

    // Change status on the server
    if (space != null) {
      return await changePinnedStatus(square, space.id, "-");
    }
    return null;
  }

  /// Rename a pinned shared space.
  ///
  /// Returns an error if there was one.
  static Future<String?> changePinnedName(Square square, PinnedSharedSpace space, String name) async {
    // Generate a new container for the square
    final newContainer = SquareContainer.copy(square.container as SquareContainer);
    final index = newContainer.spaces.indexOf(space);
    if (index == -1) {
      return "not.found".tr;
    }
    newContainer.spaces[index] = PinnedSharedSpace(space.id, name);

    // Set the new data
    return await ConversationService.setData(square, newContainer);
  }

  /// Change the pin status on the chat server.
  ///
  /// Returns an error if there was one.
  static Future<String?> changePinnedStatus(Square square, String id, String underlying) async {
    final json = await postNodeJSON("/conversations/shared_spaces/pin_status", {
      "token": square.token.toMap(square.id),
      "data": {"id": id, "underlying": underlying},
    });
    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }

  /// Change the name on the chat server.
  ///
  /// Returns an error if there was one.
  static Future<String?> renameSharedSpace(Square square, String id, String name) async {
    final json = await postNodeJSON("/conversations/shared_spaces/rename", {
      "token": square.token.toMap(square.id),
      "data": {"id": id, "name": encryptSymmetric(name, square.key)},
    });
    if (!json["success"]) {
      return json["error"];
    }
    return null;
  }

  /// Refresh the container of a Square.
  static Future<String?> refreshContainer(Square square, SquareContainer container) {
    return ConversationService.setData(square, container);
  }
}
