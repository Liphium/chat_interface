import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpacesMessageController extends GetxController {}

class SpacesMessageProvider extends MessageProvider {
  @override
  Future<Message?> loadMessageFromServer(String id, {bool init = true}) async {
    final event = await spaceConnector.sendActionAndWait(ServerAction("msg_get", id));
    if (event == null) {
      return null;
    }
    final message = await unpackMessageInIsolate(event.data["message"]);
    return message;
  }

  @override
  Future<(List<Message>?, bool)> loadMessagesAfter(int time) {
    // TODO: implement loadMessagesAfter
    throw UnimplementedError();
  }

  @override
  Future<(List<Message>?, bool)> loadMessagesBefore(int time) {
    // TODO: implement loadMessagesBefore
    throw UnimplementedError();
  }

  /// Unpack a message json in an isolate.
  ///
  /// Also verifies the signature (but that happens in the main isolate).
  ///
  /// For the future also: TODO: Unpack the signature in a different isolate
  static Future<Message> unpackMessageInIsolate(Map<String, dynamic> json) async {
    // Run an isolate to parse the message
    final (message, info) = await _extractMessageIsolate(json, Get.find<SpaceMemberController>().members, SpacesController.key!);

    // Verify the signature
    if (info != null) {
      message.verifySignature(info);
    }

    return message;
  }

  static Future<(Message, SymmetricSequencedInfo?)> _extractMessageIsolate(
      Map<String, dynamic> json, Map<String, SpaceMember> members, SecureKey key) {
    return sodiumLib.runIsolated(
      (sodium, keys, pairs) {
        // Unpack the actual message
        final (msg, info) = messageFromJson(
          json,
          sodium: sodium,
          key: keys[0],
        );

        // Unpack the system message attachments in case needed
        if (msg.type == MessageType.system) {
          // TODO: Handle system message attachments
        }

        // Return it to the main isolate
        return (msg, info);
      },
      secureKeys: [key],
    );
  }

  /// Load a message from json (from the server) and get the corresponding [SymmetricSequencedInfo] (only if no system message).
  ///
  /// **Doesn't verify the signature**
  static (Message, SymmetricSequencedInfo?) messageFromJson(
    Map<String, dynamic> json, {
    LPHAddress? space,
    Map<String, SpaceMember>? members,
    SecureKey? key,
    Sodium? sodium,
  }) {
    // Convert to message
    members ??= Get.find<SpaceMemberController>().members;
    final account = members[json["sender"]]!.friend.id;
    var message = Message(json["id"], MessageType.text, json["data"], "", [], account, account, DateTime.fromMillisecondsSinceEpoch(json["creation"]),
        LPHAddress.from(json["conversation"]), json["edited"], false);

    // Decrypt content
    key ??= SpacesController.key!;
    if (message.sender == MessageController.systemSender) {
      message.verified.value = true;
      message.type = MessageType.system;
      message.loadContent();
      sendLog("SYSTEM MESSAGE");
      return (message, null);
    }

    // Check signature
    final info = SymmetricSequencedInfo.extract(message.content, key, sodium);
    message.content = info.text;
    message.loadContent();

    return (message, info);
  }
}
