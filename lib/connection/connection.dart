
import 'package:chat_interface/connection/impl/messages/message_listener.dart';
import 'package:chat_interface/connection/impl/status_listener.dart';
import 'package:chat_interface/connection/impl/stored_actions_listener.dart';
import 'package:chat_interface/pages/status/setup/fetch/fetch_finish_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/logging_framework.dart';
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

  void connect(String url, String token) {
    initialized = true;
    connection = WebSocketChannel.connect(Uri.parse(url), protocols: [token]);

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
        // TODO: Limit connection attempts
        sendLog("restarting..");
        initialized = false;
        setupManager.restart();
      },
    );
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

void startConnection(String node, String connectionToken) async {
  if(connector.initialized) return;
  connector.connect("ws://$node/gateway", connectionToken);

  setupSetupListeners();
  setupStoredActionListener();
  setupStatusListener();
  setupMessageListener();
}