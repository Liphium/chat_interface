import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/publication_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/src/rust/api/interaction.dart' as api;
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/spaces/gamemode/spaces_game_hub.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:window_manager/window_manager.dart';

class SpacesController extends GetxController {
  //* Call status
  final inSpace = false.obs;
  final spaceLoading = false.obs;
  final connected = false.obs;
  final start = DateTime.now().obs;

  //* Game mode
  final playMode = false.obs;
  final gameShelf = false.obs;

  //* Space information
  static String? currentDomain;
  static Room? livekitRoom;
  final id = "".obs;
  static SecureKey? key;

  //* Call layout
  final hideSidebar = false.obs;
  final fullScreen = false.obs;
  final hasVideo = false.obs;
  final hideOverlay = false.obs;
  final cinemaWidget = Rx<Widget?>(null);

  void toggleFullScreen() {
    fullScreen.toggle();
    if (fullScreen.value) {
      windowManager.setFullScreen(true);
    } else {
      windowManager.setFullScreen(false);
    }
  }

  void cinemaMode(Widget widget) {
    if (cinemaWidget.value != null) {
      if (cinemaWidget.value == widget) {
        cinemaWidget.value = null;
        return;
      }
      cinemaWidget.value = widget;
      return;
    }
    cinemaWidget.value = widget;
  }

  void createSpace(bool publish) {
    _startSpace((container) {
      if (publish) {
        Get.find<StatusController>().share(container);
      }
    });
  }

  void createAndConnect(String conversationId) {
    _startSpace((container) => sendActualMessage(spaceLoading, conversationId, MessageType.call, [], container.toInviteJson(), "", () => {}));
  }

  void inviteToCall(String conversationId) {
    sendActualMessage(spaceLoading, conversationId, MessageType.call, [], getContainer().toInviteJson(), "", () => {});
  }

  SpaceConnectionContainer getContainer() {
    return SpaceConnectionContainer(currentDomain!, id.value, key!, null);
  }

  void switchToPlayMode() {
    playMode.value = !playMode.value;
    if (playMode.value) {
      Get.offAll(const SpacesGameHub(), transition: Transition.fadeIn);
      hideSidebar.value = true;
    } else {
      hideSidebar.value = false;
      Get.offAll(getChatPage(), transition: Transition.fadeIn);
    }
  }

  void openShelf() {
    gameShelf.value = !gameShelf.value;
  }

  void _startSpace(Function(SpaceConnectionContainer) callback, {Function()? connectedCallback}) {
    if (connected.value) {
      showErrorPopup("error", "already.calling");
      return;
    }
    spaceLoading.value = true;

    connector.sendAction(msg.Message("spc_start", <String, dynamic>{}), handler: (event) {
      if (!event.data["success"]) {
        if (event.data["message"] == "server.error") {
          spaceLoading.value = false;
          return _openNotAvailable();
        }
        spaceLoading.value = false;
        return showErrorPopup("error", "server.error");
      }
      final appToken = event.data["token"] as Map<String, dynamic>;
      final roomId = event.data["id"];
      sendLog("connecting to node ${appToken["node"]}..");
      key = randomSymmetricKey();
      id.value = roomId;
      _connectToRoom(roomId, appToken, connectedCallback: connectedCallback);

      // Send invites
      final container = SpaceConnectionContainer(appToken["domain"], roomId, key!, null);
      callback.call(container);
    });
  }

  void _openNotAvailable() {
    showErrorPopup("Spaces", "Spaces is currently unavailable. If you are an administrator, make sure this feature is enabled and verify that the servers are online.");
  }

  void join(SpaceConnectionContainer container) {
    connector.sendAction(
        msg.Message("spc_join", <String, dynamic>{
          "id": container.roomId,
        }), handler: (event) {
      if (!event.data["success"]) {
        if (event.data["message"] == "already.in.space") {
          showConfirmPopup(ConfirmWindow(
            title: "spaces".tr,
            text: "chat.space.leave".tr,
            onDecline: () => {},
            onConfirm: () {
              connector.sendAction(msg.Message("spc_leave", <String, dynamic>{}), handler: (event) {
                if (!event.data["success"]) {
                  if (event.data["message"] == "server.error") {
                    return _openNotAvailable();
                  }
                  return showErrorPopup("How?",
                      "I don't understand this world anymore. I'm sorry. It seems like this feature is currently pretty broken for you, tell the developers about it and we'll fix it sometime, yk like never?");
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
      id.value = container.roomId;
      key = container.key;

      // Connect to the room
      _connectToRoom(id.value, event.data["token"]);
    });
  }

  void _connectToRoom(String id, Map<String, dynamic> appToken, {Function()? connectedCallback}) async {
    if (key == null) {
      sendLog("key is null: can't connect to space");
      return;
    }
    currentDomain = appToken["domain"];

    // Setup all controllers
    Get.find<PublicationController>().onConnect();
    Get.find<SpaceMemberController>().onConnect(key!);

    // Connect to space node
    final result = await createSpaceConnection(appToken["domain"], appToken["token"]);
    sendLog("COULD CONNECT TO SPACE NODE: $result");
    if (!result) {
      showErrorPopup("error", "server.error");
      spaceLoading.value = false;
      return;
    }

    spaceConnector.sendAction(
      msg.Message(
        "setup",
        <String, dynamic>{
          "data": encryptSymmetric(StatusController.ownAccountId, key!),
        },
      ),
      handler: (event) async {
        if (!event.data["success"]) {
          showErrorPopup("error", "server.error");
          spaceLoading.value = false;
          return;
        }

        // Connect to new voice chat
        final keyProvider = await BaseKeyProvider.create();
        await keyProvider.setKey(base64Encode(key!.extractBytes()));
        livekitRoom = Room(
          roomOptions: RoomOptions(
            e2eeOptions: E2EEOptions(
              keyProvider: keyProvider,
            ),
            defaultAudioPublishOptions: const AudioPublishOptions(
              audioBitrate: 128000,
            ),
          ),
        );
        await livekitRoom!.connect(
          event.data["url"],
          event.data["token"],
          connectOptions: const ConnectOptions(
            autoSubscribe: false,
          ),
        );
        Get.find<SpaceMemberController>().onLivekitConnected();
        if (!configDisableRust) {
          await api.startTalkingEngine();
        }

        // Open the screen
        Get.find<MessageController>().unselectConversation();
        Get.find<MessageController>().openTab(OpenTabType.space);

        // Reset everything on the table
        Get.find<TabletopController>().resetControllerState();

        connected.value = true;
        inSpace.value = true;
        spaceLoading.value = false;
        connectedCallback?.call();
      },
    );
  }

  void leaveCall({error = false}) async {
    inSpace.value = false;
    connected.value = false;
    if (!configDisableRust) {
      await api.stop();
    }
    id.value = "";
    spaceConnector.disconnect();
    livekitRoom?.disconnect();

    // Tell other controllers about it
    Get.find<StatusController>().stopSharing();
    Get.find<SpaceMemberController>().onDisconnect();
    Get.find<PublicationController>().disconnect();
    Get.find<GameHubController>().leaveCall();
    Get.find<TabletopController>().disconnect(leave: false);

    if (!error) {
      Get.offAll(getChatPage(), transition: Transition.fadeIn);
      Get.find<MessageController>().openTab(OpenTabType.conversation);
    }
  }

  /// Called every time the room updates
  void updateRoomVideoState() {
    hasVideo.value = livekitRoom!.remoteParticipants.values.any((element) => element.isCameraEnabled() || element.isScreenShareEnabled()) ||
        livekitRoom!.localParticipant!.isCameraEnabled() ||
        livekitRoom!.localParticipant!.isScreenShareEnabled();
    sendLog("UPDATE VIDEO ${hasVideo.value}");
  }
}

class SpaceInfo {
  late bool exists;
  bool error = false;
  late DateTime start;
  final List<Friend> friends = [];
  late final List<String> members;

  SpaceInfo(this.start, this.members) {
    error = false;
    exists = true;
    final controller = Get.find<FriendController>();
    for (var member in members) {
      final friend = controller.friends[member];
      if (friend != null) friends.add(friend);
    }
  }

  SpaceInfo.fromJson(SpaceConnectionContainer container, Map<String, dynamic> json) {
    start = DateTime.fromMillisecondsSinceEpoch(json["start"]);
    members = List<String>.from(json["members"].map((e) => decryptSymmetric(e, container.key)));
    exists = true;

    final controller = Get.find<FriendController>();
    for (var member in members) {
      final friend = controller.friends[member];
      if (friend != null) friends.add(friend);
    }
  }

  SpaceInfo.notLoaded({bool wasError = false}) {
    exists = false;
    error = wasError;
    members = [];
  }
}

class SpaceConnectionContainer extends ShareContainer {
  final String node; // Node domain
  final String roomId; // Token required for joining (even though it's not really a token)
  final SecureKey key; // Symmetric key

  final info = Rx<SpaceInfo?>(null);
  int errorCount = 0;
  Timer? _timer;
  bool get cancelled => _timer == null;

  SpaceConnectionContainer(this.node, this.roomId, this.key, Friend? sender) : super(sender, ShareType.space);
  SpaceConnectionContainer.fromJson(Map<String, dynamic> json, [Friend? sender]) : this(json["node"], json["id"], unpackageSymmetricKey(json["key"]), sender);

  @override
  Map<String, dynamic> toMap() {
    return {"node": node, "id": roomId, "key": packageSymmetricKey(key)};
  }

  String toInviteJson() => jsonEncode({"node": node, "id": roomId, "key": packageSymmetricKey(key)});

  @override
  void onDrop() {
    _timer?.cancel();
  }

  Future<SpaceInfo> getInfo({bool timer = false}) async {
    // Request the info from the server
    final http.Response req;
    try {
      req = await http.post(
        Uri.parse("${nodeProtocol()}$node/info"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"room": roomId}),
      );
    } catch (e) {
      return SpaceInfo.notLoaded(wasError: true);
    }

    // Return a not loaded state if the request wasn't successful
    if (req.statusCode != 200) {
      return SpaceInfo.notLoaded(wasError: true);
    }

    // Parse the json
    final body = jsonDecode(req.body);

    // Start a periodic timer to refresh info (if desired)
    if (timer && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        final newInfo = await getInfo();
        if (!newInfo.exists) {
          errorCount++;
          if (errorCount > 2) {
            _timer?.cancel();
            _timer = null;
          }
        }
        info.value = newInfo;
      });
    }

    // Return a not loaded state if the request wasn't successful
    if (!body["success"]) {
      return SpaceInfo.notLoaded();
    }

    // Return the proper info
    info.value = SpaceInfo.fromJson(this, body);
    return info.value!;
  }
}
