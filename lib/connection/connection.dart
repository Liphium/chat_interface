import 'dart:convert';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/hash.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/impl/live_share_listener.dart';
import 'package:chat_interface/connection/impl/messages/message_listener.dart';
import 'package:chat_interface/connection/impl/status_listener.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:web_socket/web_socket.dart';

import 'impl/setup_listener.dart';
import 'messaging.dart';

int nodeId = 0;
String nodeDomain = "";

class Connector {
  WebSocket? connection;
  final _handlers = <String, Function(Event)>{};
  final _afterSetup = <String, bool>{};
  final _afterSetupQueue = <Event>[];
  bool initialized = false;
  bool _connected = false;
  RSAPublicKey? nodePublicKey;
  Uint8List? aesKey;
  String? aesBase64;
  String? url;

  // For handling responses
  final _responders = <String, Function(Event)?>{};
  final _responseTo = <String, String>{};

  Future<bool> connect(String url, String token, {bool restart = true, Function(bool)? onDone}) async {
    this.url = url;

    // Generate an AES key for the connection
    aesKey = randomAESKey();
    aesBase64 = base64Encode(aesKey!);

    // Grab public key from the node
    final normalizedUrl = url.replaceAll("ws://", "").replaceAll("wss://", "").split("/")[0];
    final res = await post(Uri.parse("${nodeProtocol()}$normalizedUrl/pub"));
    if (res.statusCode != 200) {
      sendLog("COULDN'T GET NODE PUBLIC KEY");
      return false;
    }

    final json = jsonDecode(res.body);
    nodePublicKey = unpackageRSAPublicKey(json['pub']);
    sendLog("RETRIEVED NODE PUBLIC KEY: $nodePublicKey");

    // Encrypt AES key for the node
    final encryptedKey = encryptRSA(aesKey!, nodePublicKey!);

    initialized = true;
    try {
      connection = await WebSocket.connect(Uri.parse(url));
    } catch (e) {
      sendLog("FAILED TO CONNECT TO $url: $e");
      return false;
    }
    _connected = true;

    connection!.sendText(jsonEncode({
      "token": token,
      "attachments": base64Encode(encryptedKey),
    }));

    connection!.events.listen(
      (message) {
        if (message is CloseReceived) {
          sendLog("CLOSE RECEIVED");
          return;
        }

        // Make sure the message is binary data
        if (message is! BinaryDataReceived) {
          sendLog("RECEIVED INVALID EVENT: $message");
          return;
        }
        final encrypted = message.data;

        // Decrypt the message (using the AES key)
        Uint8List msg;
        try {
          msg = decryptAES(encrypted, aesBase64!);
        } catch (e) {
          sendLog("HASH: ${hashShaBytes(encrypted)}");

          sendLog("FAILED TO DECRYPT MESSAGE with key ${aesBase64!}");
          sendLog(
              "This is most likely due to another client being in the same network, connected over the same port as you are. We can't do anything about this and this will not occur in production.");
          e.printError();
          return;
        }

        // Decode the message
        Event event = Event.fromJson(utf8.decode(msg));

        // Check if it is a response
        if (event.name.startsWith("res:")) {
          // Check if the event is valid
          final args = event.name.split(":");
          if (args.length != 3) {
            sendLog("response isn't valid");
            return;
          }

          // Get all the variables from the format (res:action:answerId)
          final action = args[1];
          final answerId = args[2];

          // Check if the event is different
          if (action != _responseTo[answerId]) {
            sendLog("wrong response to ${_responseTo[answerId]}, received $action instead");
          }

          // If there is a responder call it
          if (_responders[answerId] != null) {
            _responders[answerId]!.call(event);
          }
          _responders.remove(answerId);
          _responseTo.remove(answerId);
          return;
        }

        // Check if there is a handler
        if (_handlers[event.name] == null) {
          sendLog("no event handler for ${event.name}");
          return;
        }

        // Add it to the after setup queue (in case it is an after setup handler)
        if (_afterSetup[event.name] == true && !SetupManager.setupFinished && !Get.find<ConnectionController>().connected.value) {
          _afterSetupQueue.add(event);
          return;
        }

        // Call the handler
        _handlers[event.name]!(event);
      },
      cancelOnError: false,
      onDone: () {
        _connected = false;
        if (onDone != null) {
          onDone(false);
        }
        if (restart) {
          Get.find<ConnectionController>().connectionStopped();
        }
        initialized = false;
      },
      onError: (e) {
        sendLog("ERROR: $e");
        e.printError();
        onDone?.call(true);
        _connected = false;
      },
    );

    return true;
  }

  void disconnect() {
    _connected = false;
    try {
      connection?.close();
    } catch (_) {}
  }

  void runAfterSetupQueue() {
    for (var event in _afterSetupQueue) {
      _handlers[event.name]!(event);
    }
  }

  bool isConnected() {
    return _connected;
  }

  /// Listen for an [Event] from the node.
  ///
  /// [afterSetup] specifies whether the handler should be called after the setup is finished.
  void listen(String event, Function(Event) handler, {afterSetup = false}) {
    // Make sure no handler is registered for the claimed action "res" (for handling responses)
    if (event == "res") {
      sendLog("You can't register an event handler for 'res'. This is already used by the system to handle responses.");
      SystemNavigator.pop();
    }

    _handlers[event] = handler;
    _afterSetup[event] = afterSetup;
  }

  /// Send a [Message] to the node.
  ///
  /// Optionally, you can specify a [handler] to handle the response (this will be called multiple times if there are multiple responses).
  /// Optionally, you can specify a [waiter] to wait for the response.
  void sendAction(Message message, {Function(Event)? handler}) {
    if (!_connected) {
      showErrorPopup("error", "error.network".tr);
      sendLog("TRIED TO SEND ACTION WHILE NOT CONNECTED: ${message.action}");
      return;
    }

    // Generate a valid response id
    var responseId = getRandomString(5);
    while (_responders.containsKey(responseId)) {
      responseId = getRandomString(5);
    }

    // Register the handler and waiter
    _responders[responseId] = handler;
    _responseTo[responseId] = message.action;

    // Add responseId to action
    message.action = "${message.action}:$responseId";

    // Send and encrypt the message (using AES key)
    connection?.sendBytes(encryptAES(message.toJson().toCharArray().unsignedView(), aesBase64!));
  }
}

/// The [Connector] to the chat node.
Connector connector = Connector();

/// Initialize the connection to the chat node.
Future<bool> startConnection(String node, String connectionToken) async {
  sendLog(node);
  if (connector.initialized) return false;
  final res = await connector.connect(isHttps ? "wss://$node/gateway" : "ws://$node/gateway", connectionToken);
  if (!res) {
    return false;
  }

  setupSetupListeners();
  setupStoredActionListener();
  setupStatusListener();
  setupMessageListener();
  setupLiveshareListening();

  // Add listeners for Spaces (unrelated to chat node)
  setupSpaceListeners();

  return true;
}
