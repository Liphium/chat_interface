import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationMembers extends StatelessWidget {
  const ConversationMembers({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<MessageController>();

    return Padding(
      padding: const EdgeInsets.all(defaultSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
            child: Text('chat.members'.trParams({"count":controller.selectedConversation.value.members.length.toString()}), style: Theme.of(context).textTheme.titleMedium),
          ),
          verticalSpacing(defaultSpacing),
          ListView.builder(
            shrinkWrap: true,
            itemCount: controller.selectedConversation.value.members.length,
            itemBuilder: (context, index) {
              final member = controller.selectedConversation.value.members.values.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: defaultSpacing),
                child: UserRenderer(id: member.account),
              );
            },
          ),
        ],
      ),
    );
  }
}