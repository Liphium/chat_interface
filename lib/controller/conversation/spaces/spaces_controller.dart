import 'dart:async';
import 'dart:convert';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart' as msg;
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/settings/town/tabletop_settings.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sodium_libs/sodium_libs.dart';
import 'package:window_manager/window_manager.dart';

bool areSpacesSupported = !isWeb && !GetPlatform.isMobile;

class SpacesController extends GetxController {
  //* Call status
  final inSpace = false.obs;
  final spaceLoading = false.obs;
  final connected = false.obs;
  final start = DateTime.now().obs;
  final currentTab = SpaceTabType.table.index.obs;
  int _prevTab = SpaceTabType.table.index;

  //* Space information
  static String? currentDomain;
  final id = "".obs;
  static SecureKey? key;

  //* Call layout
  final chatOpen = true.obs;
  final hideSidebar = false.obs;
  final fullScreen = false.obs;

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

  void createSpace(bool publish) {
    _startSpace((container) {
      if (publish) {
        Get.find<StatusController>().share(container);
      }
    });
  }

  void createAndConnect(MessageProvider provider) {
    if (!areSpacesSupported) {
      showNotSupported();
      return;
    }

    _startSpace((container) => provider.sendMessage(spaceLoading, MessageType.call, [], container.toInviteJson(), ""));
  }

  void showNotSupported() {
    showErrorPopup("spaces.not_supported", "spaces.not_supported.desc".tr);
  }

  void inviteToCall(MessageProvider provider) {
    provider.sendMessage(spaceLoading, MessageType.call, [], getContainer().toInviteJson(), "");
  }

  SpaceConnectionContainer getContainer() {
    return SpaceConnectionContainer(currentDomain!, id.value, key!, null);
  }

  void _startSpace(Function(SpaceConnectionContainer) callback, {Function()? connectedCallback}) async {
    if (connected.value) {
      showErrorPopup("error", "spaces.already_calling".tr);
      return;
    }
    spaceLoading.value = true;

    // Create a new space
    final roomId = getRandomString(16);
    key = randomSymmetricKey();
    id.value = roomId;
    final domain = await _connectToRoom(roomId, connectedCallback: connectedCallback);
    if (domain == null) {
      return;
    }

    // Send invites
    final container = SpaceConnectionContainer(domain, roomId, key!, null);
    callback.call(container);
  }

  void join(SpaceConnectionContainer container) async {
    spaceLoading.value = true;

    // Load information from space container
    id.value = container.roomId;
    key = container.key;

    // Connect to the room
    await _connectToRoom(id.value);
    spaceLoading.value = false;
  }

  /// Returns the domain of the node the Space is hosted on.
  Future<String?> _connectToRoom(String id, {Function()? connectedCallback}) async {
    final body = await postAuthorizedJSON("/node/connect", <String, dynamic>{
      "tag": appTagSpaces,
      "token": refreshToken,
      "extra": id,
    });

    // Return an error
    if (!body["success"]) {
      showErrorPopup("error", "server.error".tr);
      sendLog("WARNING: couldn't connect to space node");
      return null;
    }

    if (key == null) {
      sendLog("key is null: can't connect to space");
      return null;
    }
    currentDomain = body["domain"];
    currentTab.value = SpaceTabType.table.index;

    // Setup all controllers
    Get.find<SpaceMemberController>().onConnect(key!);

    // Connect to space node
    final result = await createSpaceConnection(body["domain"], body["token"]);
    sendLog("COULD CONNECT TO SPACE NODE: $result");
    if (!result) {
      showErrorPopup("error", "server.error".tr);
      spaceLoading.value = false;
      return null;
    }

    spaceConnector.sendAction(
      msg.ServerAction(
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
        Get.find<SpacesMessageController>().open();

        // Reset everything on the table
        Get.find<TabletopController>().resetControllerState();
        Get.find<TabletopController>().openTableTab();

        connected.value = true;
        inSpace.value = true;
        chatOpen.value = true;
        spaceLoading.value = false;
        connectedCallback?.call();
      },
    );

    return body["domain"];
  }

  void leaveCall({error = false}) async {
    inSpace.value = false;
    connected.value = false;
    id.value = "";
    spaceConnector.disconnect();

    // Tell other controllers about it
    Get.find<StatusController>().stopSharing();
    Get.find<SpaceMemberController>().onDisconnect();
    Get.find<TabletopController>().resetControllerState();
    Get.find<SpacesMessageController>().clearProvider();

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
