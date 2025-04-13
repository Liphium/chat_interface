import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SidebarController {
  static final rightSidebar = mapSignal<String, RightSidebar?>({});
  static final hideSidebar = signal(false);
  static final loaded = signal(false);
  static final currentOpenTab = signal<SidebarTab>(DefaultSidebarTab());

  /// Set the right sidebar for the current sidebar tab.
  static void setRightSidebar(RightSidebar? tab) {
    rightSidebar[currentOpenTab.peek().key] = tab;
    if (Get.width <= 1200) {
      if (tab != null) {
        hideSidebar.value = true;
      } else {
        hideSidebar.value = false;
      }
    }
  }

  /// Toggle the open state of the main sidebar.
  static void toggleSidebar() {
    hideSidebar.value = !hideSidebar.peek();
    if (Get.width <= 1200 && rightSidebar[currentOpenTab.peek().key] != null) {
      rightSidebar[currentOpenTab.peek().key] = null;
    }
  }

  /// Set a new tab for the sidebar.
  static void openTab(SidebarTab tab) {
    try {
      if (!(rightSidebar[currentOpenTab.peek().key]?.cache ?? true)) {
        rightSidebar.remove(currentOpenTab.peek().key);
      }
      currentOpenTab.value = tab;
    } catch (e) {
      sendLog("WANRING: The weird exception happened again.");
    }
  }

  /// Get the current message provider (in case the current tab is a [ConversationSidebarTab]).
  ///
  /// No subscriptions are made during this call, for that use [getCurrentProviderReactive].
  static ConversationMessageProvider? getCurrentProvider() {
    final tab = currentOpenTab.peek();
    if (tab is ConversationSidebarTab) {
      return tab.provider;
    }
    return null;
  }

  /// Get the current message provider (in case the current tab is a [ConversationSidebarTab]).
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

  /// Helper function to get the current key (for the current open sidebar tab)
  static String getCurrentKey() {
    return currentOpenTab.peek().key;
  }
}

enum SidebarTabType { none, conversation, space }

abstract class SidebarTab {
  final String key;
  final SidebarTabType type;

  SidebarTab(this.type, this.key);

  Widget build(BuildContext context);
}

abstract class RightSidebar {
  final String key;
  final bool cache;

  RightSidebar(this.key, {this.cache = false});

  Widget build(BuildContext context);
}
