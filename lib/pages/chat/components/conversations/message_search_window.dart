import 'dart:math';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_search_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/material/material_message_renderer.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageSearchWindow extends StatefulWidget {
  const MessageSearchWindow({super.key});

  @override
  State<MessageSearchWindow> createState() => _MessageSearchWindowState();
}

class _MessageSearchWindowState extends State<MessageSearchWindow> {
  final FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final searchController = Get.find<MessageSearchController>();

    return Container(
      color: Get.theme.colorScheme.onInverseSurface,
      padding: EdgeInsets.symmetric(vertical: elementSpacing, horizontal: defaultSpacing + elementSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FJTextField(
            focusNode: _focus,
            prefixIcon: Icons.search,
            hintText: "search".tr,
            onChange: (query) {
              final controller = Get.find<MessageController>();
              if (controller.currentProvider.value == null) {
                return;
              }
              sendLog(controller.currentProvider.value!.messages.length);
              searchController.filters.value = [
                ConversationFilter(controller.currentProvider.value!.conversation.id.encode()),
                ContentFilter(query),
              ];
              searchController.search();
            },
          ),
          verticalSpacing(defaultSpacing),
          Obx(() {
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: searchController.results.length,
              itemBuilder: (context, index) {
                final message = searchController.results[index];
                final friend = friendController.friends[message.senderAddress];

                return Padding(
                  padding: const EdgeInsets.only(bottom: defaultSpacing),
                  child: Material(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color: Get.theme.colorScheme.inverseSurface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      onTap: () => {},
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: MaterialMessageRenderer(
                          message: message,
                          provider: null,
                          senderAddress: message.senderAddress,
                          sender: friend,
                          overwritePadding: 0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          })
        ],
      ),
    );
  }
}
