import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemMessages {
  static final messages = {

    // Called when a member is promoted/demoted
    // Format: [prevRole, newRole, memberId, senderId]
    "group.rank_change": SystemMessage(
      Icons.shield,
      handler: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        conversation.fetchMembers(msg.createdAt);
      },
      translation: (msg) {
        final friendController = Get.find<FriendController>();
        return "chat.rank_change.${msg.attachments[0]}->${msg.attachments[1]}".trParams({
          "name": friendController.getFriend(msg.attachments[2]).name,
          "sender": friendController.getFriend(msg.attachments[3]).name, // NZJNP232RS5g
        });
      }
    ),

    // Called when a member generates a new conversation token
    // Format: [memberId]
    "group.token_change": SystemMessage(
      Icons.vpn_key,
      handler: (msg) => {},
      translation: (msg) {
        return "chat.token_change".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      }
    ),

    // Called when a member joins the conversation
    // Format: [memberId]
    "group.member_join": SystemMessage(
      Icons.arrow_forward,
      handler: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        conversation.fetchMembers(msg.createdAt);
      },
      translation: (msg) {
        return "chat.member_join".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      }
    ),

    // Called when a member leaves the conversation
    // Format: [memberId]
    "group.member_leave": SystemMessage(
      Icons.arrow_back,
      handler: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        conversation.fetchMembers(msg.createdAt);
      },
      translation: (msg) {
        return "chat.member_leave".trParams({
          "name": Get.find<FriendController>().getFriend(msg.attachments[0]).name,
        });
      }
    ),

    // Called when the conversation should be deleted
    // Format: []
    "group.deleted": SystemMessage(
      Icons.delete,
      store: false,
      render: false,
      handler: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        conversation.delete();
      },
      translation: (msg) {
        return "chat.deleted".tr;
      }
    )
  };
}

class SystemMessage {
  final IconData icon;
  final bool render; // TODO: Implement
  final bool store; // TODO: Implement
  final String Function(Message) translation;
  final Function(Message) handler;

  SystemMessage(this.icon, {required this.handler, required this.translation, this.render = false, this.store = false});

  void handle(Message message) {
    message.decryptSystemMessageAttachments();
    handler.call(message);
  }
}