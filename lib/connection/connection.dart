
import 'package:chat_interface/main.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'messaging.dart';

class Connector {

  late WebSocketChannel connection;

  Connector(String url) {
    connection = WebSocketChannel.connect(Uri.parse(url));

    connection.stream.listen((msg) {

    Event event = Event.fromJson(msg);

      
      
    });

    connection.stream.handleError((err) {
      logger.e(err);
      connection.sink.close();
    });
  }

  void sendMessage(String message) {
    connection.sink.add(message);
  }

}