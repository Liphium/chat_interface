import 'dart:convert';

import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SquareContainer extends ConversationContainer {
  late List<Topic> topics;
  late List<PinnedSharedSpace> spaces;

  SquareContainer(super.name, this.topics, this.spaces);

  @override
  SquareContainer.fromJson(Map<String, dynamic> json) : super(json["name"]) {
    // Parse all of the topics
    topics = [];
    if (json["topics"] != null) {
      for (var topic in json["topics"]) {
        topics.add(Topic.fromJson(topic));
      }
    }

    // Parse all of the spaces
    spaces = [];
    if (json["spaces"] != null) {
      for (var space in json["spaces"]) {
        spaces.add(PinnedSharedSpace.fromJson(space));
      }
    }
  }

  @override
  factory SquareContainer.decrypt(String cipherText, SecureKey key) {
    return SquareContainer.fromJson(jsonDecode(decryptSymmetric(cipherText, key)));
  }

  factory SquareContainer.copy(SquareContainer other) {
    return SquareContainer(other.name, [...other.topics], [...other.spaces]);
  }

  @override
  String encrypted(SecureKey key) {
    return encryptSymmetric(jsonEncode(toJson()), key);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json["topics"] = topics.map((t) => t.toJson()).toList();
    json["spaces"] = spaces.map((s) => s.toJson()).toList();
    return json;
  }
}

class Topic {
  final String id;
  final String name;

  Topic(this.id, this.name);
  Topic.fromJson(Map<String, dynamic> json) : this(json["id"], json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class PinnedSharedSpace {
  final String id;
  final String name;

  bool loading = false; // Loading state for the UI

  PinnedSharedSpace(this.id, this.name);
  PinnedSharedSpace.fromJson(Map<String, dynamic> json) : this(json["id"], json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
