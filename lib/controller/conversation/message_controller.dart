import 'dart:async';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_members_bar.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/pages/chat/messages_page.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class MessageController {
  // Constants
  static Message? hoveredMessage;
  static AttachmentContainer? hoveredAttachment;
  static LPHAddress systemSender = LPHAddress("liphium.com", "6969");

  static final loaded = signal(false);

  /// Open a conversation.
  ///
  /// Transitions to a new page on mobile.
  /// Changes the tab in the sidebar in case on desktop.
  static Future<void> openConversation(Conversation conversation, {String extra = ""}) async {
    final provider = ConversationMessageProvider(conversation, extra: extra);

    // Load the current position for messages
    final read = conversation.reads.get(extra);
    await provider.loadNewMessagesTop(date: DateTime.now().millisecondsSinceEpoch);

    // Show the messages once they are fully loaded
    loaded.value = true;

    // Open page or provider (here to prevent flicker)
    if (isMobileMode()) {
      // On mobile transition to the page
      unawaited(Get.to(MessagesPageMobile(provider: provider)));
    } else {
      // Open the sidebar tab
      SidebarController.openTab(ConversationSidebarTab(provider));

      // Open the member sidebar in case desired
      if (SettingController.settings[AppSettings.showGroupMembers]!.getValue() as bool && conversation.isGroup) {
        SidebarController.setRightSidebar(ConversationMembersRightSidebar(conversation));
      }
    }
  }

  /// Restore the right sidebar to how it was before another sidebar was opened.
  ///
  /// Returns the sidebar to the group members overview for example (in case opened).
  static void restoreRightSidebar() {
    if (SettingController.settings[AppSettings.showGroupMembers]!.getValue() as bool) {
      final provider = SidebarController.getCurrentProvider();
      if (provider != null && provider.conversation.isGroup) {
        SidebarController.setRightSidebar(ConversationMembersRightSidebar(provider.conversation));
      } else {
        SidebarController.setRightSidebar(null);
      }
    } else {
      SidebarController.setRightSidebar(null);
    }
  }

  /// Add a message to the cache.
  ///
  /// [simple] can be set to [true] in case you want to only add the message (no extra fancy stuff).
  static Future<bool> addMessage(
    Message message,
    Conversation conversation, {
    String extra = "",
    bool simple = false,
    (String, String)? part,
  }) async {
    // Make sure there even is a conversation
    var tab = SidebarController.currentOpenTab.peek();
    if (tab is! ConversationSidebarTab) {
      return true; // Success, nothing could be done (xd)
    }

    // Add message to message history if it's the selected one
    if (tab.provider.conversation.id == conversation.id) {
      if (message.senderToken != tab.provider.conversation.token.id && !simple) {
        await ConversationService.overwriteRead(
          tab.provider.conversation,
          message.createdAt.millisecondsSinceEpoch,
          extra: extra,
        );
      }

      // Check if it is a system message and if it should be rendered or not
      if (message.type == MessageType.system) {
        if (SystemMessages.messages[message.content]?.render == true) {
          unawaited(tab.provider.addMessageToBottom(message));
        }
      } else {
        // Store normal type of message
        unawaited(tab.provider.addMessageToBottom(message));
      }
    }

    return true;
  }
}
