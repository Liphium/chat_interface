import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/pages/chat/components/conversations/notification_dot.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/services/squares/square_service.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SquareTopicList extends StatefulWidget {
  final Square square;

  const SquareTopicList({super.key, required this.square});

  @override
  State<SquareTopicList> createState() => _SquareTopicListState();
}

class _SquareTopicListState extends State<SquareTopicList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: sectionSpacing),
      child: Watch((ctx) {
        final container = widget.square.containerSub.value as SquareContainer;

        // Only render when the topics are shown
        if (!widget.square.topicsShown.value) {
          return SizedBox();
        }

        // Render the actual topic list
        return ReorderableListView.builder(
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) async {
            // Create a new container with the order changed
            final copied = SquareContainer.copy(container);

            // Add at the new index
            final removed = container.topics.removeAt(oldIndex);
            container.topics.insert(oldIndex > newIndex ? newIndex : newIndex - 1, removed);

            // Change on the server, reset in case didn't work
            final error = await SquareService.refreshContainer(widget.square, container);
            if (error != null) {
              widget.square.containerSub.value = copied;
              showErrorPopup("error", error);
            } else {
              widget.square.containerSub.value = container;
            }
          },
          buildDefaultDragHandles: false,
          itemCount: container.topics.length,
          itemBuilder: (context, index) {
            final topic = container.topics[index];
            return ReorderableDelayedDragStartListener(
              key: ValueKey("topic-${widget.square.id.encode()}-${topic.id}"),
              index: index,
              child: Container(
                color: Get.theme.colorScheme.onInverseSurface,
                padding: const EdgeInsets.only(top: elementSpacing),
                child: Watch(
                  (ctx) => Material(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    color:
                        (SidebarController.getCurrentProviderReactive()?.extra ?? "") == topic.id
                            ? Get.theme.colorScheme.onSurface.withAlpha(20)
                            : Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      hoverColor: Get.theme.hoverColor,
                      splashColor: Get.theme.hoverColor,

                      // When topic is tapped (open topic)
                      onTap: () {
                        // Make sure to not open when already open on desktop
                        if ((SidebarController.getCurrentProvider()?.extra ?? "") == topic.id && !isMobileMode()) {
                          return;
                        }
                        MessageController.openConversation(widget.square, extra: topic.id);
                      },
                      onSecondaryTapDown: (details) {
                        // TODO: Open topic context menu
                        sendLog("TO-DO: topic context menu here");
                      },

                      // Topic item content
                      child: Padding(
                        padding: const EdgeInsets.all(elementSpacing2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.numbers),
                                  horizontalSpacing(elementSpacing2),
                                  Flexible(
                                    child: Text(
                                      topic.name,
                                      style:
                                          (SidebarController.getCurrentProviderReactive()?.extra ?? "") == topic.id
                                              ? Get.theme.textTheme.labelMedium
                                              : Get.theme.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            horizontalSpacing(elementSpacing2),
                            Watch((ctx) {
                              final notifications =
                                  ConversationController.notificationMap[ConversationService.withExtra(
                                    widget.square.id.encode(),
                                    topic.id,
                                  )] ??
                                  0;

                              return Visibility(
                                visible: notifications > 0,
                                child: NotificationDot(amount: notifications),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }, dependencies: [widget.square.topicsShown, widget.square.containerSub]),
    );
  }
}
