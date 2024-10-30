import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/game_hub_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sodium_libs/sodium_libs.dart';
import 'package:window_manager/window_manager.dart';

bool areCallsSupported = !isWeb && !GetPlatform.isMobile;

class SpacesController extends GetxController {
  //* Call status
  final inSpace = false.obs;
  final spaceLoading = false.obs;
  final connected = false.obs;
  final start = DateTime.now().obs;
  final currentTab = SpaceTabType.people.index.obs;
  int _prevTab = SpaceTabType.people.index;

  //* Space information
  static String? currentDomain;
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

  /// Switch to a tab programatically
  void switchToTabAndChange(SpaceTabType type) {
    currentTab.value = type.index;
    switchToTab(type);
  }

  /// Event that is called after the tab switch was done through the selector
  void switchToTab(SpaceTabType type) {
    if (type.index == _prevTab) {
      return;
    }

    // If the previous tab was the table, disconnect from the event stream
    if (_prevTab == SpaceTabType.table.index) {
      Get.find<TabletopController>().closeTableTab();
    }

    // If the current tab is a table tab, connect to the event stream
    if (type == SpaceTabType.table) {
      Get.find<TabletopController>().openTableTab();
    }
    _prevTab = currentTab.value;
  }

  void cinemaMode(Widget widget) {
    sendLog("cinema");
    if (cinemaWidget.value != null) {
      if (cinemaWidget.value == widget) {
        sendLog("already cinema");
        if (currentTab.value == SpaceTabType.people.index) {
          switchToTabAndChange(SpaceTabType.cinema);
        } else {
          switchToTabAndChange(SpaceTabType.people);
        }
        return;
      }
      cinemaWidget.value = widget;
      switchToTabAndChange(SpaceTabType.cinema);
      return;
    }
    cinemaWidget.value = widget;
    switchToTabAndChange(SpaceTabType.cinema);
  }

  void createSpace(bool publish) {
    _startSpace((container) {
      if (publish) {
        Get.find<StatusController>().share(container);
      }
    });
  }

  void createAndConnect(LPHAddress conversationId) {
    _startSpace((container) => sendActualMessage(spaceLoading, conversationId, MessageType.call, [], container.toInviteJson(), "", () => {}));
  }

  void inviteToCall(LPHAddress conversationId) {
    sendActualMessage(spaceLoading, conversationId, MessageType.call, [], getContainer().toInviteJson(), "", () => {});
  }

  SpaceConnectionContainer getContainer() {
    return SpaceConnectionContainer(currentDomain!, id.value, key!, null);
  }

  void _startSpace(Function(SpaceConnectionContainer) callback, {Function()? connectedCallback}) {
    if (connected.value) {
      showErrorPopup("error", "already.calling".tr);
      return;
    }
    spaceLoading.value = true;

    connector.sendAction(msg.Message("spc_start", <String, dynamic>{}), handler: (event) {
      if (!event.data["success"]) {
        spaceLoading.value = false;
        sendLog(event.data);
        if (event.data["message"] is String) {
          return showErrorPopup("error", event.data["message"]);
        }
        return showErrorPopup("error", "server.error".tr);
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

  void join(SpaceConnectionContainer container) {
    connector.sendAction(
        msg.Message("spc_join", <String, dynamic>{
          "id": container.roomId,
        }), handler: (event) {
      if (!event.data["success"]) {
        if (event.data["message"] == "already.in.space") {
          // Leave the space immediately
          connector.sendAction(msg.Message("spc_leave", <String, dynamic>{}), handler: (event) async {
            if (!event.data["success"]) {
              if (event.data["message"] is String) {
                return showErrorPopup("error", event.data["message"]);
              }
              return showErrorPopup("error", "server.error".tr);
            }

            // Wait a little bit, in case a server abuses this as an infinite loop
            await Future.delayed(const Duration(milliseconds: 500));

            // Try joining again
            join(container);
          });
          return;
        }

        return showErrorPopup("error", "server.error".tr);
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
    currentTab.value = SpaceTabType.people.index;

    // Setup all controllers
    Get.find<SpaceMemberController>().onConnect(key!);

    // Connect to space node
    final result = await createSpaceConnection(appToken["domain"], appToken["token"]);
    sendLog("COULD CONNECT TO SPACE NODE: $result");
    if (!result) {
      showErrorPopup("error", "server.error".tr);
      spaceLoading.value = false;
      return;
    }

    spaceConnector.sendAction(
      msg.Message(
        "setup",
        {
          "data": encryptSymmetric(StatusController.ownAddress.encode(), key!),
          "color": Get.find<SettingController>().settings[TabletopSettings.cursorHue]!.getValue() as double,
        },
      ),
      handler: (event) async {
        if (!event.data["success"]) {
          showErrorPopup("error", "server.error".tr);
          spaceLoading.value = false;
          return;
        }

        // Open the screen
        Get.find<MessageController>().unselectConversation();
        Get.find<MessageController>().openTab(OpenTabType.space);

        // Reset everything on the table
        Get.find<TabletopController>().resetControllerState();
        Get.find<TabletopController>().openTableTab();

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
    id.value = "";
    spaceConnector.disconnect();

    // Tell other controllers about it
    Get.find<StatusController>().stopSharing();
    Get.find<SpaceMemberController>().onDisconnect();
    Get.find<GameHubController>().leaveCall();
    Get.find<TabletopController>().resetControllerState();

    if (!error) {
      Get.offAll(getChatPage(), transition: Transition.fadeIn);
      Get.find<MessageController>().openTab(OpenTabType.conversation);
    }
  }
}

enum SpaceTabType {
  table("spaces.tab.table"),
  people("spaces.tab.people"),
  cinema("spaces.tab.cinema");

  final String name;

  const SpaceTabType(this.name);
}

class SpaceInfo {
  late bool exists;
  bool error = false;
  late DateTime start;
  final List<Friend> friends = [];
  late final List<LPHAddress> members;

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
    members = List<LPHAddress>.from(json["members"].map((e) => LPHAddress.from(decryptSymmetric(e, container.key))));
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
  SpaceConnectionContainer.fromJson(Map<String, dynamic> json, [Friend? sender])
      : this(json["node"], json["id"], unpackageSymmetricKey(json["key"]), sender);

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
