
import 'package:chat_interface/connection/connection.dart';

Connector spaceConnector = Connector();

void createSpaceConnection(String domain, String token) {
  spaceConnector.connect("ws://$domain/gateway", token);
}