import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/conversation/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/standards/server_stored_information.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpacesMessageController extends GetxController {
  SpacesMessageProvider provider = SpacesMessageProvider();

  /// Clear the chat log for the provider (aka reset the provider).
  void clearProvider() {
    provider = SpacesMessageProvider();
  }

  /// Add a message to the Spaces chat.
  ///
  /// Also plays a notification sound if desired by the user.
  void addMessage(Message message) {
    // Play a notification sound when a new message arrives
    RingingManager.playNotificationSound();

    // Check if it is a system message and if it should be rendered or not
    if (message.type == MessageType.system) {
      if (SystemMessages.messages[message.content]?.render == true) {
        provider.addMessageToBottom(message);
      }
    } else {
      // Store normal type of message
      if (provider.messages.isNotEmpty && provider.messages[0].id != message.id) {
        provider.addMessageToBottom(message);
      } else if (provider.messages.isEmpty) {
        provider.addMessageToBottom(message);
      }
    }

    // Handle system messages
    if (message.type == MessageType.system) {
      SystemMessages.messages[message.content]?.handle(message, provider);
    }
  }
}

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
  Future<(List<Message>?, bool)> loadMessagesAfter(int time) async {
    // Load the messages from the server using the list_before endpoint
    final event = await spaceConnector.sendActionAndWait(ServerAction("msg_list_after", time));
    if (event == null) {
      return (null, true);
    }

    // Check if there was an error
    if (!event.data["success"]) {
      newMessagesLoading.value = false;
      return (null, true);
    }

    // Check if the bottom has been reached
    if (event.data["messages"] == null || event.data["messages"].isEmpty) {
      newMessagesLoading.value = false;
      return (null, false);
    }

    // Unpack the messages in an isolate
    return (await _processMessages(event.data["messages"]), false);
  }

  @override
  Future<(List<Message>?, bool)> loadMessagesBefore(int time) async {
    // Load messages from the server
    final event = await spaceConnector.sendActionAndWait(ServerAction("msg_list_before", time));
    if (event == null) {
      return (null, true);
    }

    // Check if there was an error
    if (!event.data["success"]) {
      newMessagesLoading.value = false;
      return (null, true);
    }

    // Check if the top has been reached
    if (event.data["messages"] == null || event.data["messages"].isEmpty) {
      newMessagesLoading.value = false;
      return (null, false);
    }

    // Process the messages in a seperate isolate
    return (await _processMessages(event.data["messages"]), false);
  }

  @override
  Future<String?> deleteMessage(Message message) async {
    sendLog("deleting messages doesn't work here yet");
    return null;
  }

  @override
  Future<bool> deleteMessageFromClient(String id) async {
    sendLog("deleting messages doesn't work here yet");
    return false;
  }

  /// Process a message payload from the server in an isolate.
  ///
  /// All the json decoding and decryption is running in one isolate, only the verification of
  /// the signature is ran in the main isolate due to constraints with libsodium.
  ///
  /// For the future: TODO: Also process the signatures in the isolate by preloading profiles
  Future<List<Message>> _processMessages(List<dynamic> json) async {
    // Unpack the messages in an isolate (in a separate thread yk)
    final loadedMessages = await sodiumLib.runIsolated(
      (sodium, keys, pairs) async {
        // Process all messages
        final list = <(Message, SymmetricSequencedInfo?)>[];
        for (var msgJson in json) {
          final (message, info) = messageFromJson(
            msgJson,
            key: keys[0],
            sodium: sodium,
          );

          // Don't render system messages that shouldn't be rendered (this is only for safety, should never actually happen)
          if (message.type == MessageType.system && SystemMessages.messages[message.content]?.render == false) {
            continue;
          }

          // Decrypt system message attachments
          if (message.type == MessageType.system) {
            message.decryptSystemMessageAttachments(keys[0], sodium);
          }

          list.add((message, info));
        }

        // Return the list to the main isolate
        return list;
      },
      secureKeys: [SpacesController.key!],
    );

    // Init the attachments on all messages and verify signatures
    for (var (msg, info) in loadedMessages) {
      if (info != null) {
        msg.verifySignature(info);
      }
      await msg.initAttachments(this);
    }

    return loadedMessages.map((tuple) => tuple.$1).toList();
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
        json["edited"], false);

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

  @override
  SecureKey encryptionKey() {
    return SpacesController.key!;
  }

  @override
  Future<(String, int)?> getTimestamp() async {
    final event = await spaceConnector.sendActionAndWait(ServerAction("msg_timestamp", {}));
    if (event == null) {
      return null;
    }

    // Retrieve the token and the stamp from the response
    return (event.data["token"] as String, (event.data["time"] as num).toInt());
  }

  @override
  Future<String?> handleMessageSend(String timeToken, String data) async {
    final event = await spaceConnector.sendActionAndWait(ServerAction("msg_send", {
      "token": timeToken,
      "data": data,
    }));

    // Return a server error if the thing didn't work
    if (event == null) {
      return "server.error".tr;
    }

    // Return the error if there is one
    if (!event.data["success"]) {
      return event.data["message"];
    }
    return null;
  }
}
