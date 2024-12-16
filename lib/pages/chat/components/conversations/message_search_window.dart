import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_search_controller.dart';
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
    final searchController = Get.find<MessageSearchController>();

    return Container(
      color: Get.theme.colorScheme.onInverseSurface,
      padding: EdgeInsets.symmetric(vertical: defaultSpacing, horizontal: sectionSpacing),
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
              itemCount: searchController.results.length,
              itemBuilder: (context, index) {
                final message = searchController.results[index];
                return Text("${message.senderAddress.id} wrote ${message.content} on ${message.createdAt}");
              },
            );
          })
        ],
      ),
    );
  }
}
