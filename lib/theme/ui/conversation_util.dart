import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_dev_window.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_edit_window.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationUtil {
  /// Get an appropriate icon for the current conversation.
  static IconData getIconForConversation(Conversation conversation, {String extra = ""}) {
    if (extra != "") {
      return Icons.numbers;
    }
    return conversation.getIconForConversation();
  }

  /// Get an appropriate name for the current conversation.
  static String getNameForConversation(Conversation conversation, {String extra = ""}) {
    // Return the current topic name in case it's a square
    if (conversation is Square) {
      final container = conversation.containerSub.value as SquareContainer;
      if (extra == "") {
        return container.name;
      }
      return container.topics.firstWhereOrNull((t) => t.id == extra)?.name ?? container.name;
    }

    // Return the name or the name of the friend depending on the type
    return conversation.isGroup ? conversation.containerSub.value.name : conversation.dmName;
  }

  /// Open the appropriate dialog for the conversation.
  static void openDialogForConversation(Conversation conversation, ContextMenuData data, {String extra = ""}) {
    // Open topic specific or conversation edit dialog
    if (conversation is Square && extra != "") {
      showModal(ConversationEditWindow(position: data, conversation: conversation, extra: extra));
      return;
    }

    // Open the profile in case it's a direct message
    if (!conversation.isGroup) {
      // Create the function that generates the actions for the friend
      List<ProfileAction> buildActions(Friend friend) {
        final actions = ProfileDefaults.buildDefaultActions(friend, messageAction: false);

        // Add an action to open the developer window
        actions.insert(
          0,
          ProfileAction(
            icon: Icons.developer_mode,
            label: "For developers",
            onTap: (_, _) => showModal(ConversationDevWindow(conversation: conversation)),
          ),
        );

        // Add an action to leave the conversation
        actions.add(
          ProfileAction(
            icon: Icons.logout,
            label: "conversations.leave".tr,
            onTap:
                (_, _) => showConfirmPopup(
                  ConfirmWindow(
                    title: "conversations.leave".tr,
                    text: "conversations.leave.text".tr,
                    onConfirm: () {
                      conversation.delete();
                      Get.back();
                    },
                    onDecline: () => {},
                  ),
                ),
            color: Get.theme.colorScheme.onError,
            iconColor: Get.theme.colorScheme.error,
          ),
        );
        return actions;
      }

      showModal(Profile(friend: conversation.otherMember, data: data, actions: buildActions));
      return;
    }

    // Show the conversation edit window for everything else
    showModal(ConversationEditWindow(position: data, conversation: conversation));
  }
}
