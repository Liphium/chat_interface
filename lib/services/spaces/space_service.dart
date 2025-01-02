import 'package:chat_interface/connection/encryption/signatures.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/controller/current/steps/key_step.dart';
import 'package:chat_interface/controller/spaces/space_container.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpaceService {
  /// Connect to a space using its connection container
  static Future<String?> connectToSpace(String domain, String spaceId, SecureKey key) async {
    // Ask the server for a join token
    final spaceJson = await postAddress(
      domain,
      "/join",
      {
        "id": spaceId,
      },
      noApiVersion: true,
    );
    if (!spaceJson["success"]) {
      return spaceJson["error"];
    }

    // Connect to the space
    final error = await _connectToRoom(domain, spaceJson["token"], spaceJson["client"], spaceId, key);
    if (error != null) {
      return error;
    }

    return null;
  }

  /// Create a new space (returns an error if there was one)
  static Future<(SpaceConnectionContainer?, String?)> createSpace() async {
    // Get a connection token for Spaces (required to create a new space)
    final json = await postAuthorizedJSON("/node/connect", <String, dynamic>{
      "tag": appTagSpaces,
      "token": refreshToken,
      "extra": "",
    });
    if (!json["success"]) {
      return (null, json["error"] as String);
    }

    // Send a request to the space node for creating a new space
    final spaceJson = await postAddress(
      json["domain"],
      "/create",
      {
        "token": json["token"],
      },
      noApiVersion: true,
    );
    if (!spaceJson["success"]) {
      return (null, spaceJson["error"] as String);
    }

    // Connect to the space
    final key = randomSymmetricKey();
    final error = await _connectToRoom(json["domain"], spaceJson["token"], spaceJson["client"], spaceJson["space"], key);
    if (error != null) {
      return (null, error);
    }

    // Return a connection container for the space
    final container = SpaceConnectionContainer(json["domain"], spaceJson["id"], key, null);
    return (container, null);
  }

  /// Returns an error if there was one
  static Future<String?> _connectToRoom(String server, String token, String clientId, String spaceId, SecureKey key) async {
    // Connect to space node
    final result = await createSpaceConnection(server, token);
    sendLog("COULD CONNECT TO SPACE NODE");
    if (!result) {
      return "server.error".tr;
    }

    // Send the server all the data required for setup
    final toSign = "$spaceId:$clientId:${StatusController.ownAddress.encode()}";
    final event = await spaceConnector.sendActionAndWait(msg.ServerAction("setup", {
      "data": encryptSymmetric(StatusController.ownAddress.encode(), key),
      "signature": signMessage(signatureKeyPair.secretKey, toSign),
    }));
    if (event == null) {
      return "server.error".tr;
    }
    if (!event.data["success"]) {
      return event.data["message"];
    }

    Get.find<SpacesController>().onConnect(spaceId, key);

    return null;
  }
}
