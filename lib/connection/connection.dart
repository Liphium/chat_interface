
import 'package:chat_interface/connection/impl/calls/calls_listener.dart';
import 'package:chat_interface/connection/impl/friends/friend_listener.dart';
import 'package:chat_interface/connection/impl/messages/message_listener.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'impl/setup/setup_listener.dart';
import 'messaging.dart';

int nodeId = 0;
String nodeDomain = "";

class Connector {

  late WebSocketChannel connection;
  final _handlers = <String, Function(Event)>{};
  final _waiters = <String, Function()>{};
  bool initialized = false;

  void connect(String url, String token) {
    initialized = true;
    connection = WebSocketChannel.connect(Uri.parse(url), protocols: [token]);

    connection.stream.listen((msg) {
        print(msg);
        Event event = Event.fromJson(msg);

        if(_handlers[event.name] == null) return;
        _handlers[event.name]!(event);
        
        _waiters[event.name]?.call();
        _waiters.remove(event.name);
      },
      cancelOnError: false,
      onDone: () {
        initialized = false;
        setupManager.restart();
      },
    );
  }

  void sendMessage(String message) {
    connection.sink.add(message);
  }

  void listen(String event, Function(Event) handler) {
    _handlers[event] = handler;
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

  setupMessageListeners();
  setupSetupListeners();
  setupFriendListeners();
  setupCallListeners();
}