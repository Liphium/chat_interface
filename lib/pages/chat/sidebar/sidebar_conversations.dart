import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/controller/conversation/square.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/pages/chat/components/conversations/notification_dot.dart';
import 'package:chat_interface/pages/chat/components/squares/square_topic_list.dart';
import 'package:chat_interface/pages/chat/components/squares/topic_manage_window.dart';
import 'package:chat_interface/services/chat/conversation_member.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/services/chat/conversation_service.dart';
import 'package:chat_interface/services/squares/square_container.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
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
      return ListView.builder(
        controller: _controller,
        itemCount: ConversationController.order.length,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.only(top: defaultSpacing, right: defaultSpacing, left: defaultSpacing),
        itemBuilder: (context, index) {
          // Normal conversation renderer
          Conversation conversation =
              ConversationController.conversations[ConversationController.order.elementAt(index)]!;

          Friend? friend;
          if (!conversation.isGroup) {
            // Fetch the member that isn't the own account
            LPHAddress id =
                conversation.members.values
                    .firstWhere(
                      (element) => element.address != StatusController.ownAddress,
                      orElse: () => Member(LPHAddress.error(), LPHAddress.error(), MemberRole.user),
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
          return Watch(key: ValueKey("${conversation.id.encode()}-sb"), (ctx) {
            // Determine the title of the conversation based on the type
            String title;
            if (conversation.isGroup || friend == null) {
              title = conversation.containerSub.value.name;
            } else {
              title = conversation.dmName;
            }

            // Make sure to mark the conversation as archived in case the friend doesn't exist
            if (friend == null && !conversation.isGroup) {
              title = ".$title";
            }

            // Handle when hidden by search
            if (_query.value != "") {
              if (!title.toLowerCase().startsWith(_query.value.toLowerCase())) {
                return const SizedBox();
              }
            } else if (friend == null && !conversation.isGroup) {
              return const SizedBox();
            }

            return SignalHook(
              value: false,
              builder:
                  (hover) => Padding(
                    padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                    child: Watch((ctx) {
                      final provider = SidebarController.getCurrentProviderReactive();

                      return Column(
                        children: [
                          Material(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color:
                                provider?.conversation == conversation && provider?.extra == "" && !isMobileMode()
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
                                // Make sure to not open the conversation again
                                if (provider?.conversation == conversation &&
                                    provider?.extra == "" &&
                                    !isMobileMode()) {
                                  return;
                                }
                                MessageController.openConversation(conversation);
                              },
                              onSecondaryTapDown: (details) {
                                ConversationMessageProvider(
                                  conversation,
                                ).openDialogForConversation(ContextMenuData.fromPosition(details.globalPosition));
                              },

                              // Conversation item content
                              child: renderConversationItem(conversation, title, provider, friend, hover),
                            ),
                          ),

                          // Render the topic list in case open and square
                          if (conversation.type == model.ConversationType.square)
                            SquareTopicList(square: conversation as Square),
                        ],
                      );
                    }),
                  ),
            );
          });
        },
      );
    });
  }

  /// Render the item for one conversation in the list
  Padding renderConversationItem(
    Conversation conversation,
    String title,
    ConversationMessageProvider? provider,
    Friend? friend,
    Signal<bool> hover,
  ) {
    return Padding(
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
            // Make sure the user is actually connected
            if (!ConnectionController.connected.value) {
              return const SizedBox();
            }

            final notifications = ConversationController.notificationMap[conversation.id.encode()] ?? 0;
            if (hover.value) {
              // Show the create topic button in case it's a square
              if (conversation.type == model.ConversationType.square) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showModal(TopicManageWindow(square: conversation as Square));
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                );
              }

              // Show a remove button to leave the current conversation for all other types
              return IconButton(
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
            }

            return Visibility(visible: notifications > 0, child: NotificationDot(amount: notifications));
          }),

          // Show a collapse/expand topics button when it's a square
          if (conversation is Square)
            Padding(
              padding: EdgeInsets.only(left: elementSpacing),
              child: Watch((ctx) {
                final squareContainer = conversation.container as SquareContainer;
                final toggled = conversation.topicsShown.value;
                bool notifications = false;
                for (var topic in squareContainer.topics) {
                  if (ConversationController.notificationMap[ConversationService.withExtra(
                        conversation.id.encode(),
                        topic.id,
                      )] !=
                      0) {
                    notifications = true;
                    break;
                  }
                }

                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        conversation.topicsShown.value = !conversation.topicsShown.peek();
                      },
                      icon: Icon(toggled ? Icons.expand_less : Icons.expand_more),
                    ),
                    Visibility(
                      visible: notifications,
                      child: Positioned(
                        right: defaultSpacing,
                        bottom: defaultSpacing,
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Get.theme.colorScheme.error),
                          width: defaultSpacing,
                          height: defaultSpacing,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
        ],
      ),
    );
  }

  /// Render a direct message preview for the sidebar
  Widget renderDirectMessage(
    Friend? friend,
    String title,
    Conversation conversation,
    ConversationMessageProvider? provider,
  ) {
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
                          child: Icon(Icons.sensors, color: Get.theme.colorScheme.onPrimary, size: 21),
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
                      visible: friend.status.value != "" && friend.statusType.value != statusOffline,
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
  Widget renderGroup(String title, Conversation conversation, ConversationMessageProvider? provider) {
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
                          message: "conversations.different_town".trParams({"town": conversation.id.server}),
                          child: Icon(Icons.sensors, color: Get.theme.colorScheme.onPrimary, size: 21),
                        ),
                      ),
                  ],
                ),

                verticalSpacing(elementSpacing * 0.5),

                // Render the amount of members of the conversation
                Text(
                  "chat.members".trParams(<String, String>{"count": conversation.members.length.toString()}),
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
  Widget renderSquare(String title, Conversation conversation, ConversationMessageProvider? provider) {
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
                            provider?.conversation == conversation && provider?.extra == ""
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
                          message: "conversations.different_town".trParams({"town": conversation.id.server}),
                          child: Icon(Icons.sensors, color: Get.theme.colorScheme.onPrimary, size: 21),
                        ),
                      ),
                  ],
                ),

                verticalSpacing(elementSpacing * 0.5),

                // Render the amount of members of the conversation
                Text(
                  "chat.members".trParams(<String, String>{"count": conversation.members.length.toString()}),
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
