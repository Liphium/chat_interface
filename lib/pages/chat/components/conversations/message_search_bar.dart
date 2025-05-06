import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/material/material_message_renderer.dart';
import 'package:chat_interface/services/chat/message_search_query.dart';
import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

/// Right sidebar implementation for the sidebar controller
class MessageSearchRightSidebar extends RightSidebar {
  late final MessageSearchQuery query;

  // Make sure the thing is cached
  MessageSearchRightSidebar(super.key, String conversationId) : super(cache: true) {
    query = MessageSearchQuery();
    query.filters.add(ConversationFilter(conversationId));
  }

  @override
  Widget build(BuildContext context) {
    return MessageSearchSidebar(key: ValueKey(key), query: query);
  }
}

/// The actual widget doing the heavy lifting
class MessageSearchSidebar extends StatefulWidget {
  final MessageSearchQuery query;

  const MessageSearchSidebar({super.key, required this.query});

  @override
  State<MessageSearchSidebar> createState() => _MessageSearchSidebarState();
}

class _MessageSearchSidebarState extends State<MessageSearchSidebar> {
  final _queryController = TextEditingController();
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    sendLog("initialized");
    final filter = widget.query.filters.peek().firstWhereOrNull((f) => f is ContentFilter);
    _queryController.text = filter == null ? "" : (filter as ContentFilter).content;
    _controller.addListener(checkForScrollChanges);
    super.initState();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void checkForScrollChanges() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
      widget.query.search(increment: true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              prefixIcon: Icons.search,
              hintText: "search".tr,
              autofocus: true,
              controller: _queryController,
              onChange: (query) {
                final provider = SidebarController.getCurrentProvider();
                if (provider == null) {
                  return;
                }

                // Add the new filter for the query
                batch(() {
                  widget.query.filters.removeWhere((f) => f is ContentFilter);
                  widget.query.filters.add(ContentFilter(query));
                });

                // Restart the search
                widget.query.search();
              },
            ),
          ),
          verticalSpacing(defaultSpacing),
          Expanded(
            child: Watch((ctx) {
              return ListView.builder(
                controller: _controller,
                itemCount: widget.query.results.length,
                itemBuilder: (context, index) {
                  final message = widget.query.results[index];
                  final friend = FriendController.friends[message.senderAddress];

                  // Check if a timestamp should be rendered
                  bool newHeading = false;
                  if (index != 0) {
                    final lastMessage = widget.query.results[index - 1];

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
                            onTap: () => SidebarController.getCurrentProvider()!.scrollToMessage(message.id),
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
                        if (index == widget.query.results.length - 1) verticalSpacing(elementSpacing),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
