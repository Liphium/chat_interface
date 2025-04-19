import 'dart:convert';

import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SquareContainer extends ConversationContainer {
  late List<Topic> topics;

  SquareContainer(super.name, this.topics);

  @override
  SquareContainer.fromJson(Map<String, dynamic> json) : super(json["name"]) {
    topics = [];
    if (json["topics"] != null) {
      for (var topic in json["topics"]) {
        topics.add(Topic.fromJson(topic));
      }
    }
  }

  @override
  factory SquareContainer.decrypt(String cipherText, SecureKey key) {
    return SquareContainer.fromJson(jsonDecode(decryptSymmetric(cipherText, key)));
  }

  @override
  String encrypted(SecureKey key) {
    return encryptSymmetric(jsonEncode(toJson()), key);
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json["topics"] = topics.map((t) => t.toJson()).toList();
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
