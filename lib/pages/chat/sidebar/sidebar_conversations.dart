import 'dart:math';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/space_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SidebarConversationList extends StatefulWidget {
  final RxString query;

  const SidebarConversationList({
    super.key,
    required this.query,
  });

  @override
  State<SidebarConversationList> createState() => _SidebarConversationListState();
}

class _SidebarConversationListState extends State<SidebarConversationList> {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConversationController>();
    final spacesController = Get.find<SpacesController>();
    final messageController = Get.find<MessageController>();
    final friendController = Get.find<FriendController>();

    return Obx(
      () {
        final statusController = Get.find<StatusController>();
        return FadingEdgeScrollView.fromScrollView(
          child: ListView.builder(
            controller: _controller,
            itemCount: controller.order.length,
            addRepaintBoundaries: true,
            padding: const EdgeInsets.only(top: defaultSpacing),
            itemBuilder: (context, index) {
              //* Normal conversation renderer
              Conversation conversation = controller.conversations[controller.order.elementAt(index)]!;

              Friend? friend;
              if (!conversation.isGroup) {
                LPHAddress id = conversation.members.values
                    .firstWhere(
                      (element) => element.address != StatusController.ownAddress,
                      orElse: () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user),
                    )
                    .address;
                if (id.id == "-") {
                  friend = Friend.me();
                } else {
                  friend = friendController.friends[id];
                }
              }

              // Hover menu
              final hover = false.obs;

              return Column(
                key: ValueKey(conversation),
                mainAxisSize: MainAxisSize.min,
                children: [
                  //* Conversation item
                  Obx(
                    () {
                      var title = conversation.isGroup || friend == null ? conversation.containerSub.value.name : conversation.dmName;
                      if (friend == null && !conversation.isGroup) {
                        title = ".$title";
                      }

                      if (widget.query.value != "") {
                        if (!title.toLowerCase().startsWith(widget.query.value.toLowerCase())) {
                          return const SizedBox.shrink();
                        }
                      } else if (friend == null && !conversation.isGroup) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                        child: Obx(
                          () => Material(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: messageController.currentConversation.value == conversation && !isMobileMode()
                                ? Get.theme.colorScheme.onSurface.withOpacity(0.075)
                                : Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(defaultSpacing),
                              hoverColor: Get.theme.hoverColor,
                              splashColor: Get.theme.hoverColor,
                              onHover: (value) {
                                hover.value = value;
                              },

                              //* When conversation is tapped (open conversation)
                              onTap: () {
                                if (messageController.currentConversation.value == conversation && !isMobileMode()) return;
                                messageController.selectConversation(conversation);
                              },

                              //* Conversation item content
                              child: Padding(
                                padding: const EdgeInsets.all(elementSpacing2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //* Conversation info
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (conversation.isGroup || friend == null)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: elementSpacing * 0.5),
                                              child: Icon(
                                                conversation.isGroup
                                                    ? Icons.group
                                                    : friend == null
                                                        ? Icons.person_off
                                                        : Icons.person,
                                                size: 35,
                                                color: Get.theme.colorScheme.onPrimary,
                                              ),
                                            )
                                          else
                                            UserAvatar(id: friend.id, size: 40),
                                          horizontalSpacing(defaultSpacing * 0.75),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                //* Conversation title
                                                if (conversation.isGroup)
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          conversation.containerSub.value.name,
                                                          style: messageController.currentConversation.value == conversation
                                                              ? Get.theme.textTheme.labelMedium
                                                              : Get.theme.textTheme.bodyMedium,
                                                          textHeightBehavior: noTextHeight,
                                                        ),
                                                      ),
                                                      if (conversation.id.server != basePath && friend == null)
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: defaultSpacing),
                                                          child: Tooltip(
                                                            waitDuration: const Duration(milliseconds: 500),
                                                            message: "conversations.different_town".trParams({
                                                              "town": conversation.id.server,
                                                            }),
                                                            child: Icon(
                                                              Icons.sensors,
                                                              color: Get.theme.colorScheme.onPrimary,
                                                              size: 21,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  )
                                                else
                                                  Obx(() {
                                                    return Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            friend != null ? conversation.dmName : conversation.containerSub.value.name,
                                                            style: messageController.currentConversation.value == conversation
                                                                ? Get.theme.textTheme.labelMedium
                                                                : Get.theme.textTheme.bodyMedium,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            textHeightBehavior: noTextHeight,
                                                          ),
                                                        ),
                                                        if (friend != null && friend.id.server != basePath)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: defaultSpacing),
                                                            child: Tooltip(
                                                              waitDuration: const Duration(milliseconds: 500),
                                                              message: "friends.different_town".trParams({
                                                                "town": friend.id.server,
                                                              }),
                                                              child: Icon(
                                                                Icons.sensors,
                                                                color: Get.theme.colorScheme.onPrimary,
                                                                size: 21,
                                                              ),
                                                            ),
                                                          ),
                                                        horizontalSpacing(defaultSpacing),
                                                        if (friend != null) StatusRenderer(status: friend.statusType.value),
                                                      ],
                                                    );
                                                  }),

                                                friend == null
                                                    ? verticalSpacing(elementSpacing * 0.5)
                                                    : Visibility(
                                                        visible: conversation.isGroup || friend.status.value != "",
                                                        child: verticalSpacing(elementSpacing * 0.5),
                                                      ),

                                                // Conversation description
                                                conversation.isGroup
                                                    ? Text(
                                                        //* Conversation status message
                                                        "chat.members".trParams(<String, String>{'count': conversation.members.length.toString()}),

                                                        style: Get.textTheme.bodySmall,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      )
                                                    :

                                                    //* Friend status message
                                                    friend == null
                                                        ? Text(
                                                            friend != null ? friend.status.value : "friend.removed".tr,
                                                            style: Get.textTheme.bodySmall,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            textHeightBehavior: noTextHeight,
                                                          )
                                                        : Obx(
                                                            () => Visibility(
                                                              visible: friend!.status.value != "" && friend.statusType.value != statusOffline,
                                                              child: Text(
                                                                friend.status.value,
                                                                style: Get.textTheme.bodySmall,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                textHeightBehavior: noTextHeight,
                                                              ),
                                                            ),
                                                          ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Obx(
                                      () {
                                        final notifications = conversation.notificationCount.value;
                                        if (hover.value) {
                                          return IconButton(
                                            onPressed: () => showConfirmPopup(ConfirmWindow(
                                              title: "conversations.leave".tr,
                                              text: "conversations.leave.text".tr,
                                              onConfirm: () => conversation.delete(),
                                              onDecline: () => {},
                                            )),
                                            icon: const Icon(Icons.close),
                                          );
                                        }

                                        return Visibility(
                                          visible: notifications > 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Get.theme.colorScheme.error,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 3),
                                              child: Center(child: Text(min(notifications, 99).toString(), style: Get.textTheme.labelSmall)),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  //* Render shared content
                  if (friend != null)
                    Obx(() {
                      sendLog("shared stuff");
                      final content = statusController.sharedContent[friend!.id];
                      if (content == null) {
                        return const SizedBox();
                      }
                      switch (content.type) {
                        case ShareType.space:
                          final container = content as SpaceConnectionContainer;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: elementSpacing),
                            child: Obx(
                              () => Animate(
                                effects: [
                                  ExpandEffect(
                                    duration: 250.ms,
                                    curve: Curves.easeInOut,
                                    axis: Axis.vertical,
                                    alignment: Alignment.topLeft,
                                  ),
                                ],
                                target: spacesController.id.value == container.roomId ? 0.0 : 1.0,
                                child: SpaceRenderer(
                                  container: container,
                                  pollNewData: true,
                                  clickable: true,
                                  sidebar: true,
                                ),
                              ),
                            ),
                          );
                      }
                    }),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
