import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_interface/connection/encryption/aes.dart';
import 'package:chat_interface/connection/encryption/rsa.dart';
import 'package:chat_interface/connection/impl/messages/message_listener.dart';
import 'package:chat_interface/connection/impl/status_listener.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_finish_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'impl/setup_listener.dart';
import 'messaging.dart';

int nodeId = 0;
String nodeDomain = "";

class Connector {

  late WebSocketChannel connection;
  final _handlers = <String, Function(Event)>{};
  final _waiters = <String, Function()>{};
  final _afterSetup = <String, bool>{};
  final _afterSetupQueue = <Event>[];
  bool initialized = false;
  bool _connected = false;
  RSAPublicKey? nodePublicKey;
  Uint8List? aesKey;
  String? aesBase64;

  Future<bool> connect(String url, String token, {bool restart = true, Function()? onDone}) async {
    initialized = true;
    connection = WebSocketChannel.connect(Uri.parse(url), protocols: [token]);
    _connected = true;

    // Grab public key from the node
    final res = await post(Uri.parse("$nodeProtocol$nodeDomain/pub"));
    if(res.statusCode != 200) {
      return false;
    }

    final json = jsonDecode(res.body);
    nodePublicKey = unpackageRSAPublicKey(json['pub']);
    sendLog("RETRIEVED NODE PUBLIC KEY: $nodePublicKey");
    
    connection.stream.listen((encrypted) {

        // Decrypt the message (using the AES key)
        final msg = decryptAES(encrypted, aesBase64!);

        // Decode the message
        Event event = Event.fromJson(String.fromCharCodes(msg));
        if(_handlers[event.name] == null) return;

        if(_afterSetup[event.name] == true && !setupFinished) {
          _afterSetupQueue.add(event);
          return;
        }
        _handlers[event.name]!(event);
        
        _waiters[event.name]?.call();
        _waiters.remove(event.name);
      },
      cancelOnError: false,
      onDone: () {
        _connected = false;
        if(onDone != null) {
          onDone();
        }
        if(restart) {
          sendLog("restarting..");
          initialized = false;
          setupManager.restart();
        }
      },
    );

    return true;
  }

  void disconnect() {
    connection.sink.close();
  }

  void runAfterSetupQueue() {
    for(var event in _afterSetupQueue) {
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
    _handlers[event] = handler;
    _afterSetup[event] = afterSetup;
  }

  /// Send a [Message] to the node.
  /// 
  /// Optionally, you can specify a [handler] to handle the response (this will be called multiple times if there are multiple responses).
  /// Optionally, you can specify a [waiter] to wait for the response.
  void sendAction(Message message, {Function(Event)? handler, Function()? waiter}) {

    // Register the handler and waiter
    if(handler != null) {
      _handlers[message.action] = handler;
    }
    if(waiter != null) {
      _waiters[message.action] = waiter;
    }

    //* Encryption stuff
    // Check if AES key is set
    aesKey = randomAESKey();
    aesBase64 = base64Encode(aesKey!);

    // Compute the message (Format: [encrypted AES key (with RSA)][encrypted message (with AES)])
    final encryptedKey = encryptRSA(aesKey!, nodePublicKey!);
    sendLog(encryptedKey.length);
    final messageBytes = encryptedKey.toList();
    messageBytes.addAll(encryptAES(message.toJson().toCharArray().unsignedView(), aesBase64!));

    // Send the message
    connection.sink.add(messageBytes);
  }

  void wait(String action, Function() waiter) {
    _waiters[action] = waiter;
  }

}

/// The [Connector] to the chat node.
Connector connector = Connector();

/// Initialize the connection to the chat node.
Future<bool> startConnection(String node, String connectionToken) async {
  if(connector.initialized) return false;
  final res = await connector.connect("ws://$node/gateway", connectionToken);
  if(!res) {
    return false;
  }

  setupSetupListeners();
  setupStoredActionListener();
  setupStatusListener();
  setupMessageListener();

  // Add listeners for Spaces (unrelated to chat node)
  setupSpaceListeners();

  return true;
}