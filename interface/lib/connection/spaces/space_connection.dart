
import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:get/get.dart';

Connector spaceConnector = Connector();

void createSpaceConnection(String domain, String token) {
  spaceConnector.connect("ws://$domain/gateway", token, restart: false, onDone: (() {
    Get.find<SpacesController>().leaveCall();
  }));
}