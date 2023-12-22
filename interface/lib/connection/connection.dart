
import 'dart:convert';

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
  late final RSAPublicKey nodePublicKey;

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
    sendLog("RETRIEVED NODE PUBLIC KEY: $serverPublicKey");
    
    connection.stream.listen((msg) {
        sendLog(msg);
        Event event = Event.fromJson(msg);

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

  void sendMessage(String message) {
    sendLog(message);
    connection.sink.add(message);
  }

  bool isConnected() {
    return _connected;
  }

  void listen(String event, Function(Event) handler, {afterSetup = false}) {
    _handlers[event] = handler;
    _afterSetup[event] = afterSetup;
  }

  void sendAction(Message message, {Function(Event)? handler, Function()? waiter}) {

    if(handler != null) {
      _handlers[message.action] = handler;
    }

    if(waiter != null) {
      _waiters[message.action] = waiter;
    }
    
    sendMessage(message.toJson());
  }

  void wait(String action, Function() waiter) {
    _waiters[action] = waiter;
  }

}

Connector connector = Connector();

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

  // Add listeners for Spaces
  setupSpaceListeners();

  return true;
}