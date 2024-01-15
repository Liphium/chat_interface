import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/space_renderer.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/space_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final query = "".obs;
  final GlobalKey _addConvKey = GlobalKey(), _addSpaceKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    MessageController messageController = Get.find();
    FriendController friendController = Get.find();
    ConversationController controller = Get.find();
    SpacesController spacesController = Get.find();

    //* Sidebar
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground,
      ),

      //* Sidebar content
      child: Padding(
        padding: const EdgeInsets.only(top: defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* Search field
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Material(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(defaultSpacing * 1.5),
                        ),
                        color: theme.colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                          child: TextField(
                            style: theme.textTheme.labelMedium,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              focusColor: theme.colorScheme.onPrimary,
                              iconColor: theme.colorScheme.onPrimary,
                              fillColor: theme.colorScheme.onPrimary,
                              hoverColor: theme.colorScheme.onPrimary,
                              prefixIcon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
                              hintText: "conversations.placeholder".tr,
                            ),
                            onChanged: (value) {
                              query.value = value;
                            },
                            cursorColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    horizontalSpacing(defaultSpacing * 0.5),
                    SizedBox(
                      key: _addSpaceKey,
                      width: 48,
                      height: 48,
                      child: Material(
                        color: theme.colorScheme.primary,
                        child: InkWell(
                          onTap: () {
                            final RenderBox box = _addSpaceKey.currentContext?.findRenderObject() as RenderBox;

                            //* Open conversation add window
                            Get.dialog(SpaceAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing),
                            child: Icon(Icons.rocket_launch, color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                    horizontalSpacing(defaultSpacing * 0.5),
                    SizedBox(
                      key: _addConvKey,
                      width: 48,
                      height: 48,
                      child: Material(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(defaultSpacing * 1.5),
                        ),
                        color: theme.colorScheme.primary,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(defaultSpacing),
                          ),
                          onTap: () {
                            final RenderBox box = _addConvKey.currentContext?.findRenderObject() as RenderBox;

                            //* Open conversation add window
                            Get.dialog(ConversationAddWindow(position: ContextMenuData(box.localToGlobal(box.size.bottomLeft(const Offset(0, elementSpacing))), true, true)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(defaultSpacing),
                            child: Icon(Icons.chat_bubble, color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Obx(() {
              return Animate(
                effects: [
                  ExpandEffect(
                    duration: 250.ms,
                    curve: Curves.easeInOut,
                    axis: Axis.vertical,
                    alignment: Alignment.topCenter,
                  ),
                  ScaleEffect(
                    duration: 250.ms,
                    curve: Curves.easeInOut,
                    alignment: Alignment.center,
                  )
                ],
                target: query.value.isEmpty ? 0.0 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: defaultSpacing, left: defaultSpacing, right: defaultSpacing),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(defaultSpacing),
                    ),
                    padding: const EdgeInsets.all(defaultSpacing),
                    child: Text("conversations.hidden".tr, style: theme.textTheme.bodyMedium),
                  ),
                ),
              );
            }),

            //* Selected tab
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                child: Obx(
                  () {
                    final statusController = Get.find<StatusController>();
                    final length = controller.order.length + statusController.sharedContent.length;
                    int additional = 0;
                    bool renderedShared = false;
                    return ListView.builder(
                      itemCount: length,
                      addRepaintBoundaries: true,
                      padding: const EdgeInsets.only(top: defaultSpacing),
                      itemBuilder: (context, index) {
                        index -= additional;
                        final prevId = index > 0 ? controller.order.elementAt(index - 1) : null;
                        final prev = prevId != null ? controller.conversations[prevId] : null;
                        if (prev != null && !prev.isGroup) {
                          final otherGuy = prev.members.values.firstWhere((element) => element.account != statusController.id.value);

                          //* Shared content renderer
                          if (statusController.sharedContent.containsKey(otherGuy.account) && !renderedShared) {
                            additional += 1;
                            renderedShared = true;
                            final content = statusController.sharedContent[otherGuy.account]!;
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
                                      ),
                                    ),
                                  ),
                                );
                            }
                          }
                        }
                        renderedShared = false;

                        //* Normal conversation renderer
                        Conversation conversation = controller.conversations[controller.order.elementAt(index)]!;

                        Friend? friend;
                        if (!conversation.isGroup) {
                          String id = conversation.members.values.firstWhere((element) => element.account != statusController.id.value, orElse: () => Member("-", "-", MemberRole.user)).account;
                          if (id == "-") {
                            friend = Friend.me();
                          } else {
                            friend = friendController.friends[id];
                          }
                        }

                        // Hover menu
                        final hover = false.obs;

                        //* Conversation item
                        return Obx(
                          () {
                            var title = conversation.isGroup || friend == null ? conversation.containerSub.value.name : conversation.dmName;
                            if (friend == null && !conversation.isGroup) {
                              title = ".$title";
                            }

                            if (query.value != "") {
                              if (!title.toLowerCase().startsWith(query.value.toLowerCase())) {
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
                                  color: messageController.selectedConversation.value == conversation ? theme.colorScheme.primary : Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(defaultSpacing),
                                    hoverColor: theme.colorScheme.primary.withAlpha(150),
                                    splashColor: theme.hoverColor,
                                    onHover: (value) {
                                      hover.value = value;
                                    },

                                    //* When conversation is tapped (open conversation)
                                    onTap: () {
                                      if (messageController.selectedConversation.value == conversation) return;
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
                                                  Icon(
                                                      conversation.isGroup
                                                          ? Icons.group
                                                          : friend == null
                                                              ? Icons.person_off
                                                              : Icons.person,
                                                      size: 35,
                                                      color: theme.colorScheme.onPrimary)
                                                else
                                                  UserAvatar(id: friend.id, size: 40),
                                                horizontalSpacing(defaultSpacing * 0.75),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      //* Conversation title
                                                      Obx(() {
                                                        if (conversation.isGroup) {
                                                          return Text(
                                                            conversation.containerSub.value.name,
                                                            style: messageController.selectedConversation.value == conversation ? theme.textTheme.labelMedium : theme.textTheme.bodyMedium,
                                                            textHeightBehavior: noTextHeight,
                                                          );
                                                        }

                                                        return Row(
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                friend != null ? conversation.dmName : conversation.containerSub.value.name,
                                                                style: messageController.selectedConversation.value == conversation ? theme.textTheme.labelMedium : theme.textTheme.bodyMedium,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                textHeightBehavior: noTextHeight,
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
                                                              visible: conversation.isGroup || friend.status.value != "-",
                                                              child: verticalSpacing(defaultSpacing * 0.25),
                                                            ),

                                                      // Conversation description
                                                      conversation.isGroup
                                                          ? Text(
                                                              //* Conversation status message
                                                              "chat.members".trParams(<String, String>{'count': conversation.members.length.toString()}),

                                                              style: theme.textTheme.bodySmall,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            )
                                                          :

                                                          //* Friend status message
                                                          friend == null
                                                              ? Text(
                                                                  friend != null ? friend.status.value : "friend.removed".tr,
                                                                  style: theme.textTheme.bodySmall,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textHeightBehavior: noTextHeight,
                                                                )
                                                              : Obx(() => Visibility(
                                                                    visible: friend!.status.value != "-" && friend.statusType.value != statusOffline,
                                                                    child: Text(
                                                                      friend.status.value,
                                                                      style: theme.textTheme.bodySmall,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      textHeightBehavior: noTextHeight,
                                                                    ),
                                                                  )),
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
                                                    child: Center(child: Text(min(notifications, 99).toString(), style: theme.textTheme.labelSmall)),
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SidebarProfile()
          ],
        ),
      ),
    );
  }
}
