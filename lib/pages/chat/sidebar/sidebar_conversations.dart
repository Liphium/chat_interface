import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/services/chat/conversation_member.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/dispose_hook.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class SidebarConversationList extends StatefulWidget {
  final Signal<String>? query;

  const SidebarConversationList({super.key, this.query});

  @override
  State<SidebarConversationList> createState() => _SidebarConversationListState();
}

class _SidebarConversationListState extends State<SidebarConversationList> {
  final ScrollController _controller = ScrollController();
  late Signal<String> _query;

  @override
  void initState() {
    _query = widget.query ?? signal("");
    super.initState();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((ctx) {
      return FadingEdgeScrollView.fromScrollView(
        child: ListView.builder(
          controller: _controller,
          itemCount: ConversationController.order.length,
          addRepaintBoundaries: true,
          padding: const EdgeInsets.only(top: defaultSpacing),
          itemBuilder: (context, index) {
            // Normal conversation renderer
            Conversation conversation =
                ConversationController.conversations[ConversationController.order.elementAt(
                  index,
                )]!;

            Friend? friend;
            if (!conversation.isGroup) {
              // Fetch the member that isn't the own account
              LPHAddress id =
                  conversation.members.values
                      .firstWhere(
                        (element) => element.address != StatusController.ownAddress,
                        orElse:
                            () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user),
                      )
                      .address;

              // If not found, just use own friend as a backup plan
              if (id.id == "-") {
                sendLog("THIS SHOULD NOT HAPPEN, rendering me as member of conversation");
                friend = Friend.me();
              } else {
                // If found, use the actual friend of course
                friend = FriendController.friends[id];
              }
            }

            // Hover menu
            return Watch(key: ValueKey(conversation.id), (ctx) {
              var title =
                  conversation.isGroup || friend == null
                      ? conversation.containerSub.value.name
                      : conversation.dmName;
              if (friend == null && !conversation.isGroup) {
                title = ".$title";
              }

              if (_query.value != "") {
                if (!title.toLowerCase().startsWith(_query.value.toLowerCase())) {
                  return const SizedBox.shrink();
                }
              } else if (friend == null && !conversation.isGroup) {
                return const SizedBox.shrink();
              }

              return SignalHook(
                value: false,
                builder:
                    (hover) => Padding(
                      padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                      child: Watch((ctx) {
                        final provider = SidebarController.getCurrentProviderReactive();

                        return Material(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          color:
                              provider?.conversation == conversation && !isMobileMode()
                                  ? Get.theme.colorScheme.onSurface.withAlpha(20)
                                  : Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            hoverColor: Get.theme.hoverColor,
                            splashColor: Get.theme.hoverColor,
                            onHover: (value) {
                              hover.value = value;
                            },

                            // When conversation is tapped (open conversation)
                            onTap: () {
                              if (provider?.conversation == conversation && !isMobileMode()) return;
                              MessageController.openConversation(conversation);
                            },

                            // Conversation item content
                            child: Padding(
                              padding: const EdgeInsets.all(elementSpacing2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Conversation info
                                  if (conversation.type == model.ConversationType.group)
                                    renderGroup(title, conversation, provider)
                                  else if (conversation.type == model.ConversationType.square)
                                    renderSquare(title, conversation, provider)
                                  else
                                    renderDirectMessage(friend, title, conversation, provider),

                                  Watch((ctx) {
                                    final notifications = conversation.notificationCount.value;
                                    if (hover.value) {
                                      // A remove button to leave the current conversation
                                      final removeButton = IconButton(
                                        onPressed:
                                            () => showConfirmPopup(
                                              ConfirmWindow(
                                                title: "conversations.leave".tr,
                                                text: "conversations.leave.text".tr,
                                                onConfirm: () => conversation.delete(),
                                                onDecline: () => {},
                                              ),
                                            ),
                                        icon: const Icon(Icons.close),
                                      );

                                      // Also show a create topic button in case this is a square
                                      if (conversation.type == model.ConversationType.square) {
                                        return Row(
                                          children: [
                                            IconButton(onPressed: () {}, icon: Icon(Icons.add)),
                                            horizontalSpacing(elementSpacing),
                                            removeButton,
                                          ],
                                        );
                                      }

                                      return removeButton;
                                    }

                                    return Visibility(
                                      visible: notifications > 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Get.theme.colorScheme.error,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 2,
                                            bottom: 3,
                                          ),
                                          child: Center(
                                            child: Text(
                                              min(notifications, 99).toString(),
                                              style: Get.textTheme.labelSmall,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
              );
            });
          },
        ),
      );
    });
  }

  /// Render a direct message preview for the sidebar
  Widget renderDirectMessage(
    Friend? friend,
    String title,
    Conversation conversation,
    ConversationMessageProvider? provider,
  ) {
    // Get the friend associated

    return Expanded(
      child: Row(
        children: [
          // Render the avatar of the friend or a placeholder (if broken conversation)
          if (friend == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: elementSpacing * 0.5),
              child: Icon(Icons.person_off, size: 35, color: Get.theme.colorScheme.onPrimary),
            )
          else
            UserAvatar(id: friend.id, size: 40),
          horizontalSpacing(defaultSpacing * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render the name of the friend
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        conversation.dmName,
                        style:
                            provider?.conversation == conversation
                                ? Get.theme.textTheme.labelMedium
                                : Get.theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textHeightBehavior: noTextHeight,
                      ),
                    ),

                    // Render the foreign town indicator (in case needed)
                    if (friend != null && friend.id.server != basePath)
                      Padding(
                        padding: const EdgeInsets.only(left: defaultSpacing),
                        child: Tooltip(
                          waitDuration: const Duration(milliseconds: 500),
                          message: "friends.different_town".trParams({"town": friend.id.server}),
                          child: Icon(
                            Icons.sensors,
                            color: Get.theme.colorScheme.onPrimary,
                            size: 21,
                          ),
                        ),
                      ),
                    horizontalSpacing(defaultSpacing),

                    // Render status
                    if (friend != null) StatusRenderer(status: friend.statusType.value),
                  ],
                ),

                friend == null
                    ? verticalSpacing(elementSpacing * 0.5)
                    : Visibility(
                      visible: conversation.isGroup || friend.status.value != "",
                      child: verticalSpacing(elementSpacing * 0.5),
                    ),

                // Friend status message (if available)
                if (friend == null)
                  Text(
                    friend != null ? friend.status.value : "friend.removed".tr,
                    style: Get.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textHeightBehavior: noTextHeight,
                  )
                else
                  Watch(
                    (ctx) => Visibility(
                      visible:
                          friend.status.value != "" && friend.statusType.value != statusOffline,
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
    );
  }

  /// Render a group preview for the sidebar
  Widget renderGroup(
    String title,
    Conversation conversation,
    ConversationMessageProvider? provider,
  ) {
    return Expanded(
      child: Row(
        children: [
          // Render a group icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: elementSpacing * 0.5),
            child: Icon(Icons.group, size: 35, color: Get.theme.colorScheme.onPrimary),
          ),
          horizontalSpacing(defaultSpacing * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render the title of the group
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        conversation.containerSub.value.name,
                        style:
                            provider?.conversation == conversation
                                ? Get.theme.textTheme.labelMedium
                                : Get.theme.textTheme.bodyMedium,
                        textHeightBehavior: noTextHeight,
                      ),
                    ),

                    // Render remote indicator (in case needed)
                    if (conversation.id.server != basePath)
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
                ),

                verticalSpacing(elementSpacing * 0.5),

                // Render the amount of members of the conversation
                Text(
                  "chat.members".trParams(<String, String>{
                    "count": conversation.members.length.toString(),
                  }),
                  style: Get.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Render a square preview for the sidebar
  Widget renderSquare(
    String title,
    Conversation conversation,
    ConversationMessageProvider? provider,
  ) {
    return Expanded(
      child: Row(
        children: [
          // Render a square icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: elementSpacing * 0.5),
            child: Icon(Icons.public, size: 35, color: Get.theme.colorScheme.onPrimary),
          ),
          horizontalSpacing(defaultSpacing * 0.75),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Render the title of the group
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        conversation.containerSub.value.name,
                        style:
                            provider?.conversation == conversation
                                ? Get.theme.textTheme.labelMedium
                                : Get.theme.textTheme.bodyMedium,
                        textHeightBehavior: noTextHeight,
                      ),
                    ),

                    // Render remote indicator (in case needed)
                    if (conversation.id.server != basePath)
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
                ),

                verticalSpacing(elementSpacing * 0.5),

                // Render the amount of members of the conversation
                Text(
                  "chat.members".trParams(<String, String>{
                    "count": conversation.members.length.toString(),
                  }),
                  style: Get.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
