import 'dart:convert';

import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/util/encryption/symmetric_sodium.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SharedSpace {
  final String id;
  final String underlyingId;
  final String name;
  final SpaceConnectionContainer container;
  final List<String> members;

  SharedSpace(this.id, this.underlyingId, this.name, this.container, this.members);

  factory SharedSpace.fromJson(Map<String, dynamic> json, SecureKey conversationKey) {
    // Decrypt the connection container for the space
    final container = SpaceConnectionContainer.fromJson(
      jsonDecode(decryptSymmetric(json["container"], conversationKey)),
    );

    // Decrypt the members using this key (if there are any)
    List<String> members;
    if (json["members"] != null) {
      final jsonMembers = json["members"] as List<dynamic>;
      members = List<String>.filled(jsonMembers.length, "", growable: true);
      for (int i = 0; i < jsonMembers.length; i++) {
        members[i] = decryptSymmetric(jsonMembers[i], container.key);
      }
    } else {
      members = [];
    }

    // Return the actual instance of the shared space with the rest
    final name = (json["name"] ?? "") != "" ? decryptSymmetric(json["name"], conversationKey) : "";
    return SharedSpace(json["id"], json["underlying"], name, container, members);
  }

  /// Get the key for the map in the controller
  String getKey() {
    if (underlyingId == "-") {
      return "space-$id";
    }
    return "under-$underlyingId";
  }

  /// Get the key when the underlying id is used (in the controller)
  static String getKeyUnderlying(String id) {
    return "under-$id";
  }

  /// Get the key when the space id is used (in the controller)
  static String getKeySpace(String id) {
    return "space-$id";
  }
}
