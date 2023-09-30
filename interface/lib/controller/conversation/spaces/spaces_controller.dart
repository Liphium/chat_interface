import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/audio_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/ffi.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

class SpacesController extends GetxController {

  //* Call status
  @Deprecated("Not used anymore")
  final livekit = false.obs;

  final inSpace = false.obs;
  final spaceLoading = false.obs;
  final connected = false.obs;
  final title = "Space".obs;
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
        if(event.data["message"] == "server.error") {
          spaceLoading.value = false;
          return _openNotAvailable();
        }
        spaceLoading.value = false;
        return showErrorPopup("error", "server.error");
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

  void _openNotAvailable() {
    showErrorPopup("Spaces", "Spaces is currently unavailable. If you are an administrator, make sure this feature is enabled and verify that the servers are online.");
  }

  void join(SpaceConnectionContainer container) {

    connector.sendAction(msg.Message("spc_join", <String, dynamic>{
      "id": container.roomId,
    }), handler: (event) {
      if(!event.data["success"]) {
       
        if(event.data["message"] == "already.in.space") {
          showConfirmPopup(ConfirmWindow(title: "Spaces", text: "Do you really want to leave the current space?", 
            onDecline: () => {},
            onConfirm: () {
              connector.sendAction(msg.Message("spc_leave", <String, dynamic>{}), handler: (event) {
                if(!event.data["success"]) {
                  if(event.data["message"] == "server.error") {
                    return _openNotAvailable();
                  }
                  return showErrorPopup("How?", "I don't understand this world anymore. I'm sorry. It seems like this feature is currently pretty broken for you, tell the admins about it and we'll fix it sometime, yk like never?");
                }

                // Try joining again
                join(container);
              });
            }, 
          ));
          return;
        }
        
        return showErrorPopup("error", "server.error");
      }
    
      // Load information from space container
      id = container.roomId;
      key = container.key;

      // Connect to the room
      _connectToRoom(id, event.data["token"]);
    });
  }

  void _connectToRoom(String id, Map<String, dynamic> appToken) {
    if(key == null) {
      sendLog("key is null: can't connect to space");
      return;
    }

    // Setup all controllers
    Get.find<AudioController>().onConnect();
    Get.find<SpaceMemberController>().onConnect(key!);

    createSpaceConnection(appToken["domain"], appToken["token"]);
    spaceConnector.sendAction(msg.Message("setup", <String, dynamic>{
      "data": encryptSymmetric(Get.find<StatusController>().id.value, key!)
    }), handler: (event) async {
      if(!event.data["success"]) {
        showErrorPopup("error", "server.error");
        spaceLoading.value = false;
        return;
      }

      // Connect to UDP
      final domain = (appToken["domain"] as String).split(":")[0];
      await api.startVoice(
        clientId: event.data["id"], 
        verificationKey: event.data["key"], 
        encryptionKey: packageSymmetricKey(key!), 
        address: '$domain:${event.data["port"]}',
      );

      inSpace.value = true;
      spaceLoading.value = false;
    });
  }

  void leaveCall() async {
    inSpace.value = false;
    connected.value = false;
    await api.stop();
    spaceConnector.disconnect();

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