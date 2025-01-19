import 'dart:async';

import 'package:chat_interface/services/spaces/space_connection.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/controller/spaces/spaces_member_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_message_controller.dart';
import 'package:chat_interface/controller/spaces/tabletop/tabletop_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/services/spaces/space_service.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:get/get.dart';
import 'package:signals/signals.dart';
import 'package:sodium_libs/sodium_libs.dart';
import 'package:window_manager/window_manager.dart';

bool areSpacesSupported = !isWeb && !GetPlatform.isMobile;

class SpacesController {
  //* Call status
  static final spaceLoading = signal(false);
  static final connected = signal(false);
  static final start = signal(DateTime.now());
  static final currentTab = signal(SpaceTabType.space.index);
  static int _prevTab = SpaceTabType.space.index;

  //* Space information
  static String? domain;
  static String? id;
  static SecureKey? key;

  //* Call layout
  static final chatOpen = signal(true);
  static final hideSidebar = signal(false);
  static final fullScreen = signal(false);
  static final sidebarTabType = signal(SpaceSidebarTabType.chat.index);

  /// Toggle full screen in the Space
  static void toggleFullScreen() {
    fullScreen.value = !fullScreen.value;
    if (fullScreen.value) {
      windowManager.setFullScreen(true);
    } else {
      windowManager.setFullScreen(false);
    }
  }

  /// Switch to a tab programatically
  static void switchToTabAndChange(SpaceTabType type) {
    currentTab.value = type.index;
    switchToTab(type);
  }

  /// Event that is called after the tab switch was done through the selector
  static void switchToTab(SpaceTabType type) {
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
  static Future<void> createSpace(bool publish) async {
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

  /// Create a space and connect to it (with sending an invite to the message provider)
  static Future<void> createAndConnect(MessageProvider provider) async {
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

  static Future<void> join(SpaceConnectionContainer container) async {
    spaceLoading.value = true;

    // Connect to a Space
    final error = await SpaceService.connectToSpace(container.node, container.roomId, container.key);
    spaceLoading.value = false;
    if (error != null) {
      showErrorPopup("error", error);
    }
  }

  /// Function called by the space service to tell this controller about the connection
  static void onConnect(String server, String spaceId, SecureKey spaceKey) {
    // Load information from space container
    id = spaceId;
    domain = server;
    key = spaceKey;
    switchToTab(SpaceTabType.space);
    sidebarTabType.value = SpaceSidebarTabType.chat.index;

    // Open the screen
    Get.find<MessageController>().unselectConversation();
    Get.find<MessageController>().openTab(OpenTabType.space);
    Get.find<SpacesMessageController>().open();

    // Reset everything on the table
    Get.find<TabletopController>().resetControllerState();

    // Initialize the member controller
    Get.find<SpaceMemberController>().onConnect(spaceKey);

    connected.value = true;
    chatOpen.value = true;
  }

  static void showNotSupported() {
    showErrorPopup("spaces.not_supported", "spaces.not_supported.desc".tr);
  }

  static void inviteToCall(MessageProvider provider) {
    provider.sendMessage(false.obs, MessageType.call, [], getContainer().toInviteJson(), "");
  }

  /// Get a [SpaceConnectionContainer] for the current Space.
  static SpaceConnectionContainer getContainer() {
    return SpaceConnectionContainer(domain!, id!, key!, null);
  }

  /// Leave the space.
  static Future<void> leaveSpace({error = false}) async {
    // Disconnect from the space
    SpaceConnection.disconnect();

    // Update the state to reflect the change
    connected.value = false;
    id = null;
    key = null;
    domain = null;

    // Show an error if there was one
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
  people("spaces.sidebar.people");

  final String name;
  const SpaceSidebarTabType(this.name);
}
