import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SystemMessages {
  static final messages = {

    // Called when a member is promoted
    // Format: [prevRole, newRole, memberId, senderId]
    "group.rank_change": SystemMessage(
      Icons.shield,
      handler: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        conversation.fetchMembers(msg.createdAt);
      },
      translation: (msg) {
        final conversation = Get.find<ConversationController>().conversations[msg.conversation]!;
        final friendController = Get.find<FriendController>();
        return "chat.rank_change.${msg.attachments[0]}->${msg.attachments[1]}".trParams({
          "name": (conversation.members[msg.attachments[2]] ?? Member("", msg.attachments[2], MemberRole.admin)).getFriend(friendController).name,
          "sender": (conversation.members[msg.attachments[3]] ?? Member("", msg.attachments[3], MemberRole.admin)).getFriend(friendController).name, // NZJNP232RS5g
        });
      }
    ),
  };
}

class SystemMessage {
  final IconData icon;
  final String Function(Message) translation;
  final Function(Message) handler;

  SystemMessage(this.icon, {required this.handler, required this.translation});
}