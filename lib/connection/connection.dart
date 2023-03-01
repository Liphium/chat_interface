
import 'package:chat_interface/connection/impl/message_listener.dart';
import 'package:chat_interface/pages/status/initialization_page.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'messaging.dart';

class Connector {

  late WebSocketChannel connection;
  final _handlers = <String, Function(Event)>{};
  bool initialized = false;

  void connect(String url, String token) {
    initialized = true;
    connection = WebSocketChannel.connect(Uri.parse(url), protocols: [token]);

    connection.stream.listen((msg) {
        Event event = Event.fromJson(msg);
        _handlers[event.name]!(event);
      },
      cancelOnError: false,
      onDone: () {
        initialized = false;
        Get.offAll(const InitializationPage());
      },
    );
  }

  void sendMessage(String message) {
    connection.sink.add(message);
  }

  void listen(String event, Function(Event) handler) {
    _handlers[event] = handler;
  }

  void sendActionAndListen(Message message, Function(Event) handler) {
    listen(message.action, handler);
    sendMessage(message.toJson());
  }

}

Connector connector = Connector();

void startConnection(String node, String connectionToken) async {
  if(connector.initialized) return;
  connector.connect("ws://$node/gateway", connectionToken);

  setupMessageListeners();
}