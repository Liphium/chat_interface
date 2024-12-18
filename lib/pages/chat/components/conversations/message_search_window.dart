import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_search_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/material/material_message_renderer.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageSearchWindow extends StatefulWidget {
  const MessageSearchWindow({super.key});

  @override
  State<MessageSearchWindow> createState() => _MessageSearchWindowState();
}

class _MessageSearchWindowState extends State<MessageSearchWindow> {
  final ScrollController _controller = ScrollController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    _controller.addListener(checkForScrollChanges);
    Get.find<MessageSearchController>().currentFocus = _focus;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void checkForScrollChanges() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      Get.find<MessageSearchController>().search(increment: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final searchController = Get.find<MessageSearchController>();

    return Container(
      color: Get.theme.colorScheme.onInverseSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: elementSpacing,
              right: defaultSpacing + elementSpacing,
              left: defaultSpacing + elementSpacing,
            ),
            child: FJTextField(
              focusNode: _focus,
              prefixIcon: Icons.search,
              hintText: "search".tr,
              onChange: (query) {
                final controller = Get.find<MessageController>();
                if (controller.currentProvider.value == null) {
                  return;
                }
                searchController.filters.value = [
                  ConversationFilter(controller.currentProvider.value!.conversation.id.encode()),
                  ContentFilter(query),
                ];
                searchController.search();
              },
            ),
          ),
          verticalSpacing(defaultSpacing),
          Expanded(
            child: Obx(() {
              return FadingEdgeScrollView.fromScrollView(
                gradientFractionOnEnd: 0,
                child: ListView.builder(
                  controller: _controller,
                  itemCount: searchController.results.length,
                  itemBuilder: (context, index) {
                    final message = searchController.results[index];
                    final friend = friendController.friends[message.senderAddress];

                    // Check if a timestamp should be rendered
                    bool newHeading = false;
                    if (index != 0) {
                      final lastMessage = searchController.results[index - 1];

                      // Check if the last message was a day before the current one
                      if (lastMessage.createdAt.day != message.createdAt.day) {
                        newHeading = true;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: defaultSpacing,
                        right: defaultSpacing + elementSpacing,
                        left: defaultSpacing + elementSpacing,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (newHeading || index == 0)
                            Padding(
                              padding: const EdgeInsets.only(top: defaultSpacing, bottom: defaultSpacing),
                              child: Text(formatDay(message.createdAt), style: Get.theme.textTheme.labelMedium),
                            ),
                          Material(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: Get.theme.colorScheme.inverseSurface,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              onTap: () => Get.find<MessageController>().currentProvider.value!.scrollToMessage(message.id),
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
                          if (index == searchController.results.length - 1) verticalSpacing(elementSpacing)
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
