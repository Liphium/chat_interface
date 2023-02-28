import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/main.dart';

void setupMessageListeners() {
  connector.listen("ping", (event) {
    logger.i("Ping received");
  });
}