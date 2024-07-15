import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemMessages {
  static final messages = {
    // Called when a member is promoted/demoted
    // Format: [prevRole, newRole, memberId, senderId]
    "group.rank_change": SystemMessage(
      Icons.shield,
      translation: (msg) {
        final friendController = Get.find<FriendController>();
        return "chat.rank_change.${msg.attachments[0]}->${msg.attachments[1]}".trParams({
          "name": friendController.getFriend(msg.attachments[2]).name,
          "sender": friendController.getFriend(msg.attachments[3]).name, // NZJNP232RS5g
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a member generates a new conversation token
    // Format: [memberId]
    "group.token_change": SystemMessage(
      Icons.vpn_key,
      translation: (msg) {
        return "chat.token_change".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a member joins the conversation
    // Format: [memberId]
    "group.member_join": SystemMessage(
      Icons.arrow_forward,
      translation: (msg) {
        sendLog(msg.attachments[0]);
        return "chat.member_join".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a member invites a new member to the group
    // Format: [invitorId, memberId]
    "group.member_invite": SystemMessage(
      Icons.waving_hand,
      translation: (msg) {
        return "chat.member_invite".trParams({
          "invitor": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
          "name": Get.find<FriendController>().getFriend(msg.attachments[1]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a member leaves the conversation
    // Format: [memberId]
    "group.member_leave": SystemMessage(
      Icons.arrow_back,
      translation: (msg) {
        return "chat.member_leave".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a member is kicked from the conversation
    // Format: [issuerId, memberId]
    "group.member_kick": SystemMessage(
      Icons.arrow_back,
      translation: (msg) {
        return "chat.kick".trParams({
          "issuer": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
          "name": Get.find<FriendController>().getFriend(msg.attachments[1]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a member is promoted to admin after the only admin in a group leaves
    // Format: [memberId]
    "group.new_admin": SystemMessage(
      Icons.shield,
      translation: (msg) {
        return "chat.new_admin".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when someone changes something about the conversation
    // Format: [accountId]
    "conv.edited": SystemMessage(
      Icons.update,
      translation: (msg) {
        return "chat.edit_data".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      },
      handler: (msg) {
        Get.find<ConversationController>().conversations[msg.conversation]?.fetchData(0, refreshAnyway: true);
      },
    ),

    // Called when a message is deleted
    // Format: [messageId]
    "msg.deleted": SystemMessage(
      Icons.delete,
      render: false,
      handler: (msg) {
        Get.find<MessageController>().deleteMessageFromClient(msg.conversation, msg.attachments[0]);
      },
      translation: (msg) {
        return "msg.deleted".tr;
      },
    ),

    // Called when the member is unsubscribed from the conversation (due to deletion or sth)
    // Format: [accountId]
    "conv.kicked": SystemMessage(
      Icons.delete,
      render: false,
      handler: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        if (msg.attachments[0] == StatusController.ownAccountId) {
          conversation.delete(popup: false, request: false);
        }
      },
      translation: (msg) {
        return "msg.deleted".tr;
      },
    ),
  };
}

class SystemMessage {
  final IconData icon;
  final bool render;
  final String Function(Message) translation;
  final Function(Message)? handler;

  SystemMessage(this.icon, {this.handler, required this.translation, this.render = true});

  void handle(Message message) {
    handler?.call(message);
  }
}
