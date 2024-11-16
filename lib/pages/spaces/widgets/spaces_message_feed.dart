import 'package:chat_interface/controller/conversation/spaces/spaces_message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_list.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpacesMessageFeed extends StatefulWidget {
  const SpacesMessageFeed({super.key});

  @override
  State<SpacesMessageFeed> createState() => SpacesMessageFeedState();
}

class SpacesMessageFeedState extends State<SpacesMessageFeed> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MessageList(
            provider: Get.find<SpacesMessageController>().provider,
            overwritePadding: sectionSpacing,
          ),
        ),
        MessageInput(
          draft: "spaces_input",
          provider: Get.find<SpacesMessageController>().provider,
          secondary: true,
        ),
      ],
    );
  }
}
