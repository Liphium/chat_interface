import 'dart:async';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/spaces/ringing_manager.dart';
import 'package:chat_interface/controller/conversation/system_messages.dart';
import 'package:chat_interface/pages/chat/messages_page.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

enum OpenTabType {
  conversation,
  space,
  townsquare;
}

class MessageController {
  // Constants
  static Message? hoveredMessage;
  static AttachmentContainer? hoveredAttachment;
  static LPHAddress systemSender = LPHAddress("liphium.com", "6969");

  static final showSearch = signal(false);
  static final hideSidebar = signal(false);
  static final loaded = signal(false);
  static final currentOpenType = signal(OpenTabType.conversation);
  static final currentProvider = signal<ConversationMessageProvider?>(null);

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

  /// Unselect a conversation (when id is set, the current conversation will only be closed if it has that id)
  static void unselectConversation({LPHAddress? id}) {
    if (id != null && currentProvider.value?.conversation.id != id) {
      return;
    }
    currentProvider.value?.messages.clear();
    currentProvider.value = null;
  }

  /// Open a tab by its type.
  static void openTab(OpenTabType type) {
    currentOpenType.value = type;
    if (type != OpenTabType.conversation) {
      unselectConversation();
    }
  }

  /// Select a conversation in the sidebar.
  ///
  /// Should also
  static Future<void> selectConversation(Conversation conversation) async {
    batch(() {
      currentOpenType.value = OpenTabType.conversation;
      loaded.value = false;
      currentProvider.value = ConversationMessageProvider(conversation);
    });
    if (isMobileMode()) {
      unawaited(Get.to(MessagesPageMobile(provider: currentProvider.value!)));
    }
    if (conversation.notificationCount.value != 0) {
      // Send new read state to the server
      await ConversationService.overwriteRead(conversation);
    }

    // Make sure the thing has some messages in it
    await currentProvider.value!.loadNewMessagesTop(date: DateTime.now().millisecondsSinceEpoch);

    loaded.value = true;
  }

  /// Add a message to the cache.
  static Future<bool> addMessage(
    Message message,
    Conversation conversation, {
    bool simple = false,
    (String, String)? part,
  }) async {
    // Ignore certain things in case they are already done or not needed
    if (!simple) {
      // Update message read time for conversations (nessecary for notification count)
      ConversationService.updateLastMessage(
        conversation.id,
        increment: currentProvider.value?.conversation.id != conversation.id,
        messageSendTime: message.createdAt.millisecondsSinceEpoch,
      );

      // Play a notification sound when a new message arrives
      unawaited(RingingManager.playNotificationSound());
    }

    // Add message to message history if it's the selected one
    if (currentProvider.value?.conversation.id == conversation.id) {
      if (message.senderToken != currentProvider.value?.conversation.token.id && !simple) {
        await ConversationService.overwriteRead(currentProvider.value!.conversation);
      }

      // Check if it is a system message and if it should be rendered or not
      if (message.type == MessageType.system) {
        if (SystemMessages.messages[message.content]?.render == true) {
          unawaited(currentProvider.value!.addMessageToBottom(message));
        }
      } else {
        // Store normal type of message
        unawaited(currentProvider.value!.addMessageToBottom(message));
      }
    }

    return true;
  }
}
