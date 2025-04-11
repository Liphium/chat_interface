import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemMessages {
  static final messages = {
    // Called when a member is promoted/demoted
    // Format: [prevRole, newRole, memberId, senderId]
    "group.rank_change": SystemMessage(
      Icons.shield,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.rank_change.${msg.attachments[0]}->${msg.attachments[1]}".trParams({
            "name": FriendController.getFriend(LPHAddress.from(msg.attachments[2])).displayName.value,
            "sender": FriendController.getFriend(LPHAddress.from(msg.attachments[3])).displayName.value, // NZJNP232RS5g
          });
        }

        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a member generates a new conversation token
    // Format: [memberId]
    "group.token_change": SystemMessage(
      Icons.vpn_key,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.token_change".trParams({"name": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value});
        }

        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a member joins the conversation
    // Format: [memberId]
    "group.member_join": SystemMessage(
      Icons.arrow_forward,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.member_join".trParams({"name": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value});
        }

        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a member invites a new member to the group
    // Format: [invitorId, memberId]
    "group.member_invite": SystemMessage(
      Icons.waving_hand,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.member_invite".trParams({
            "invitor": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value,
            "name": FriendController.getFriend(LPHAddress.from(msg.attachments[1])).displayName.value,
          });
        }

        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a member leaves the conversation
    // Format: [memberId]
    "group.member_leave": SystemMessage(
      Icons.arrow_back,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.member_leave".trParams({"name": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value});
        }
        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a member is kicked from the conversation
    // Format: [issuerId, memberId]
    "group.member_kick": SystemMessage(
      Icons.arrow_back,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.kick".trParams({
            "issuer": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value,
            "name": FriendController.getFriend(LPHAddress.from(msg.attachments[1])).displayName.value,
          });
        }
        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a member is promoted to admin after the only admin in a group leaves
    // Format: [memberId]
    "group.new_admin": SystemMessage(
      Icons.shield,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.new_admin".trParams({"name": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value});
        }

        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when someone changes something about the conversation
    // Format: [accountId]
    "conv.edited": SystemMessage(
      Icons.update,
      store: false,
      translation: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          return "chat.edit_data".trParams({"name": FriendController.getFriend(LPHAddress.from(msg.attachments[0])).displayName.value});
        }

        return "not.supported".tr;
      },
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          ConversationService.fetchNewestVersion(provider.conversation);
        }
      },
    ),

    // Called when a message is deleted
    // Format: [messageId]
    "msg.deleted": SystemMessage(
      Icons.delete,
      render: false,
      store: false,
      handler: (msg, provider) {
        provider.deleteMessageFromClient(msg.attachments[0]);
      },
      translation: (msg, provider) {
        return "msg.deleted".tr;
      },
    ),

    // Called when the member is unsubscribed from the conversation (due to deletion or sth)
    // Format: [accountId]
    "conv.kicked": SystemMessage(
      Icons.delete,
      render: false,
      store: false,
      handler: (msg, provider) {
        if (provider is ConversationMessageProvider) {
          if (LPHAddress.from(msg.attachments[0]) == StatusController.ownAddress) {
            ConversationService.delete(provider.conversation.id, vaultId: provider.conversation.vaultId, token: provider.conversation.token);
          }
        }
      },
      translation: (msg, provider) {
        return "msg.deleted".tr;
      },
    ),
  };
}

class SystemMessage {
  final IconData icon;
  final bool render;
  final bool store;
  final String Function(Message, MessageProvider) translation;
  final Function(Message, MessageProvider)? handler;

  SystemMessage(this.icon, {this.handler, required this.translation, this.render = true, this.store = true});

  void handle(Message message, MessageProvider provider) {
    handler?.call(message, provider);
  }
}
