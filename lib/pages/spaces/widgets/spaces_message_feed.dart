import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_list.dart';
import 'package:chat_interface/pages/chat/messages/message_input.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';

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
            provider: SpaceController.provider,
            overwritePadding: sectionSpacing,
          ),
        ),
        MessageInput(
          draft: "spaces_input",
          provider: SpaceController.provider,
          secondary: true,
        ),
      ],
    );
  }
}
