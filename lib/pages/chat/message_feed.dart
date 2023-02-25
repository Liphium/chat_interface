import 'dart:math';

import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageFeed extends StatefulWidget {
  const MessageFeed({super.key});

  @override
  State<MessageFeed> createState() => _MessageFeedState();
}

class _MessageFeedState extends State<MessageFeed> {
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        ListView.builder(
          itemCount: 20,
          reverse: true,
          itemBuilder: (context, index) {
            return index != 0 ? 
            InkWell(
              onTap: () => {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.2, horizontal: defaultSpacing * 2),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                      child: const Icon(Icons.person),
                    ),
                    horizontalSpacing(defaultSpacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('chat.name'.tr),
                            horizontalSpacing(defaultSpacing * 2),
                            Text('chat.time'.tr),
                          ],
                        ),
                        verticalSpacing(defaultSpacing * 0.1),
                        Text('chat.message'.tr),
                      ],
                    )
                  ],
                ),
              ),
            ) : verticalSpacing(defaultSpacing * 9);
          },
        ),
        Padding(
          padding: const EdgeInsets.all(defaultSpacing * 2),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              elevation: 10,
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultSpacing,
                  vertical: defaultSpacing * 0.1,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.add),
                    ),
                    horizontalSpacing(defaultSpacing),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'chat.message'.tr,
                        ),
                      ),
                    ),
                    horizontalSpacing(defaultSpacing),
                    IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.message),
                    ),
                    horizontalSpacing(defaultSpacing * 0.1),
                    IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.sticky_note_2),
                    ),
                    horizontalSpacing(defaultSpacing * 0.1),
                    IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.emoji_emotions),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}