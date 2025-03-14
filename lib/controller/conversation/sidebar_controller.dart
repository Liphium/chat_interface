import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SidebarController {
  static final showSearch = signal(false);
  static final hideSidebar = signal(false);
  static final loaded = signal(false);
  static final currentOpenTab = signal<SidebarTab>(DefaultSidebarTab());

  /// Open the search view on the side of the message feed.
  ///
  /// TODO: Consider moving this to local state of the conversation (doesn't make sense here)
  static void toggleSearchView() {
    showSearch.value = !showSearch.peek();
    if (Get.width <= 1200) {
      if (showSearch.value) {
        hideSidebar.value = true;
      } else {
        hideSidebar.value = false;
      }
    }
  }

  /// Toggle the open state of the main sidebar.
  static void toggleSidebar() {
    hideSidebar.value = !hideSidebar.peek();
    if (Get.width <= 1200 && showSearch.value) {
      showSearch.value = false;
    }
  }

  /// Set a new tab for the sidebar.
  static void openTab(SidebarTab tab) {
    try {
      currentOpenTab.value = tab;
    } catch (e) {
      sendLog("WANRING: The weird exception happened again.");
    }
  }

  /// Get the current message provider (in case the current tab is a [SidebarConversationTab]).
  ///
  /// No subscriptions are made during this call, for that use [getCurrentProviderReactive].
  static ConversationMessageProvider? getCurrentProvider() {
    final tab = currentOpenTab.peek();
    if (tab is ConversationSidebarTab) {
      return tab.provider;
    }
    return null;
  }

  /// Get the current message provider (in case the current tab is a [SidebarConversationTab]).
  static ConversationMessageProvider? getCurrentProviderReactive() {
    final tab = currentOpenTab.value;
    if (tab is ConversationSidebarTab) {
      return tab.provider;
    }
    return null;
  }

  /// Helper function to unselect a specific conversation with [id].
  static void unselectConversation(LPHAddress id) {
    final provider = getCurrentProvider();
    if (provider != null && provider.conversation.id == id) {
      openTab(DefaultSidebarTab());
    }
  }
}

enum SidebarTabType {
  none,
  conversation,
  space;
}

abstract class SidebarTab {
  final SidebarTabType type;

  SidebarTab(this.type);

  Widget build(BuildContext context);
}
