import 'dart:async';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
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
  static Future<void> openConversation(Conversation conversation) async {
    final provider = ConversationMessageProvider(conversation);

    if (isMobileMode()) {
      // On mobile transition to the page
      unawaited(Get.to(MessagesPageMobile(provider: provider)));
    } else {
      // On desktop select the conversation in the sidebar
      SidebarController.openTab(ConversationSidebarTab(provider));
    }
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      await ConversationService.overwriteRead(conversation);
    }

    // Make sure the thing has some messages in it
    await provider.loadNewMessagesTop(date: DateTime.now().millisecondsSinceEpoch);

    // Show the messages once they are fully loaded
    loaded.value = true;
  }

  /// Add a message to the cache.
  ///
  /// [simple] can be set to [true] in case you want to only add the message (no extra fancy stuff).
  static Future<bool> addMessage(Message message, Conversation conversation, {bool simple = false, (String, String)? part}) async {
    // Make sure there even is a conversation
    var tab = SidebarController.currentOpenTab.peek();
    if (tab is! ConversationSidebarTab) {
      return true; // Success, nothing could be done (xd)
    }

    // Add message to message history if it's the selected one
    if (tab.provider.conversation.id == conversation.id) {
      if (message.senderToken != tab.provider.conversation.token.id && !simple) {
        await ConversationService.overwriteRead(tab.provider.conversation);
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
