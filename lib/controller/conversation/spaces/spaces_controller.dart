import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpacesController extends GetxController {

  //* Call status
  @Deprecated("Not used anymore")
  final livekit = false.obs;

  final inSpace = true.obs;
  final spaceLoading = false.obs;
  final connected = true.obs;
  final title = "just playing".obs;
  final start = DateTime.now().obs;

  //* Space information
  String id = "";
  SecureKey? key;

  //* Call layout
  final expanded = false.obs;
  final fullScreen = false.obs;
  final hasVideo = false.obs;

  void createAndConnect(String conversationId) {
    if(connected.value) {
      showErrorPopup("error", "already.calling");
      return;
    }
    spaceLoading.value = true;
                      
    connector.sendAction(msg.Message("spc_start", <String, dynamic>{}), handler: (event) {
      if(!event.data["success"]) {
        showErrorPopup("error", "server.error");
        spaceLoading.value = false;
        return;
      }
      final controller = Get.find<StatusController>();
      final appToken = event.data["token"] as Map<String, dynamic>;
      final roomId = event.data["id"];
      sendLog("connecting to node ${appToken["node"]}..");
      key = randomSymmetricKey();
      id = controller.id.value;
      _connectToRoom(roomId, appToken);

      // Send invites
      final container = SpaceConnectionContainer(appToken["domain"], roomId, key!);
      sendActualMessage(spaceLoading, conversationId, MessageType.call, "", container.toJson(), () => {});
    });
  }

  void join(SpaceConnectionContainer container) {

  }

  void _connectToRoom(String id, Map<String, dynamic> appToken) {
    key!;
    createSpaceConnection(appToken["domain"], appToken["token"]);
    connector.sendAction(msg.Message("setup", <String, dynamic>{

    }), handler: (event) {
      if(!event.data["success"]) {
        showErrorPopup("error", "server.error");
        spaceLoading.value = false;
        return;
      }
      // TODO: Connect to UDP
    });
  }

  void leaveCall() {

    // Tell other controllers about it
    Get.find<SpaceMemberController>().onDisconnect();
  }
}

class SpaceConnectionContainer {  
  final String node; // Node domain
  final String roomId; // Token
  final SecureKey key; // Symmetric key

  SpaceConnectionContainer(this.node, this.roomId, this.key);
  SpaceConnectionContainer.fromJson(Map<String, dynamic> json) : this(json["node"], json["id"], unpackageSymmetricKey(json["key"]));

  String toJson() => jsonEncode({
    "node": node,
    "id": roomId,
    "key": packageSymmetricKey(key)
  });
}