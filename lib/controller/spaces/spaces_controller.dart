import 'dart:async';

import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/spaces/space_connection.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/spaces/space_container.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_message_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/services/spaces/space_service.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:window_manager/window_manager.dart';

bool areSpacesSupported = !isWeb && !GetPlatform.isMobile;

class SpacesController extends GetxController {
  //* Call status
  final inSpace = false.obs;
  final spaceLoading = false.obs;
  final connected = false.obs;
  final start = DateTime.now().obs;
  final currentTab = SpaceTabType.space.index.obs;
  int _prevTab = SpaceTabType.space.index;

  //* Space information
  static String? currentDomain;
  final id = "".obs;
  static SecureKey? key;

  //* Call layout
  final chatOpen = true.obs;
  final hideSidebar = false.obs;
  final fullScreen = false.obs;
  final sidebarTabType = SpaceSidebarTabType.chat.index.obs;

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

  /// Create a space (publish says whether or not it should be published through status)
  Future<void> createSpace(bool publish) async {
    spaceLoading.value = true;
    final (container, error) = await SpaceService.createSpace();
    spaceLoading.value = false;
    if (error != null) {
      showErrorPopup("error", error);
      return;
    }

    if (publish) {
      unawaited(Get.find<StatusController>().share(container!));
    }
  }

  Future<void> createAndConnect(MessageProvider provider) async {
    if (!areSpacesSupported) {
      showNotSupported();
      return;
    }

    spaceLoading.value = true;
    final (container, error) = await SpaceService.createSpace();
    spaceLoading.value = false;

    if (error != null) {
      showErrorPopup("error", error);
      return;
    }

    unawaited(provider.sendMessage(spaceLoading, MessageType.call, [], container!.toInviteJson(), ""));
  }

  Future<void> join(SpaceConnectionContainer container) async {
    spaceLoading.value = true;

    // Connect to a Space
    final error = await SpaceService.connectToSpace(container.node, container.roomId, container.key);
    spaceLoading.value = false;
    if (error != null) {
      showErrorPopup("error", error);
    }
  }

  /// Function called by the space service to tell this controller about the connection
  void onConnect(String spaceId, SecureKey spaceKey) {
    // Load information from space container
    id.value = spaceId;
    key = spaceKey;
    switchToTab(SpaceTabType.space);
    sidebarTabType.value = SpaceSidebarTabType.chat.index;

    // Open the screen
    Get.find<MessageController>().unselectConversation();
    Get.find<MessageController>().openTab(OpenTabType.space);
    Get.find<SpacesMessageController>().open();

    // Reset everything on the table
    Get.find<TabletopController>().resetControllerState();

    connected.value = true;
    inSpace.value = true;
    chatOpen.value = true;
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

  Future<void> leaveCall({error = false}) async {
    inSpace.value = false;
    connected.value = false;
    id.value = "";
    spaceConnector.disconnect();

    // Tell other controllers about it
    Get.find<StatusController>().stopSharing();
    Get.find<SpaceMemberController>().onDisconnect();
    Get.find<TabletopController>().resetControllerState();
    Get.find<WarpController>().resetControllerState();
    Get.find<SpacesMessageController>().clearProvider();

    if (!error) {
      unawaited(Get.offAll(getChatPage(), transition: Transition.fadeIn));
      Get.find<MessageController>().openTab(OpenTabType.conversation);
    }
  }
}

enum SpaceTabType {
  space("spaces.tab.space"),
  table("spaces.tab.table");

  final String name;

  const SpaceTabType(this.name);
}

enum SpaceSidebarTabType {
  chat("spaces.sidebar.chat"),
  members("spaces.sidebar.members");

  final String name;
  const SpaceSidebarTabType(this.name);
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
