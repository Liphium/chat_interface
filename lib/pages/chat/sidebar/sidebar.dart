import 'dart:math';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/member_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/space_renderer.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/space_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/status_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
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
  final ScrollController _controller = ScrollController();

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
        color: theme.colorScheme.onInverseSurface,
      ),

      //* Sidebar content
      child: LayoutBuilder(builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.only(top: Get.mediaQuery.padding.top != 0 && GetPlatform.isMobile ? 0 : defaultSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show error from the connection
              SafeArea(
                bottom: false,
                child: AnimatedErrorContainer(
                  padding: const EdgeInsets.only(
                    bottom: defaultSpacing,
                    right: defaultSpacing,
                    left: defaultSpacing,
                  ),
                  message: Get.find<ConnectionController>().error,
                ),
              ),

              //* Search field
              SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Material(
                            borderRadius: BorderRadius.circular(defaultSpacing),
                            color: theme.colorScheme.primary,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: defaultSpacing * 0.5),
                              child: Row(
                                children: [
                                  horizontalSpacing(defaultSpacing),
                                  Icon(Icons.search, color: Get.theme.colorScheme.onPrimary),
                                  horizontalSpacing(defaultSpacing),
                                  Expanded(
                                    child: TextField(
                                      style: theme.textTheme.labelMedium,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusColor: theme.colorScheme.onPrimary,
                                        iconColor: theme.colorScheme.onPrimary,
                                        fillColor: theme.colorScheme.onPrimary,
                                        hoverColor: theme.colorScheme.onPrimary,
                                        hintText: "conversations.placeholder".tr,
                                        hintStyle: Get.textTheme.bodyMedium,
                                      ),
                                      onChanged: (value) {
                                        query.value = value;
                                      },
                                      cursorColor: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  horizontalSpacing(defaultSpacing * 0.5),
                                  Visibility(
                                    visible: !GetPlatform.isMobile,
                                    child: IconButton(
                                      key: _addSpaceKey,
                                      onPressed: () {
                                        final RenderBox box = _addSpaceKey.currentContext?.findRenderObject() as RenderBox;

                                        //* Open conversation add window
                                        showModal(SpaceAddWindow(position: box.localToGlobal(box.size.bottomLeft(const Offset(0, 5)))));
                                      },
                                      icon: Icon(Icons.rocket_launch, color: theme.colorScheme.onPrimary),
                                    ),
                                  ),
                                  horizontalSpacing(defaultSpacing * 0.5),
                                  IconButton(
                                    key: _addConvKey,
                                    onPressed: () {
                                      final RenderBox box = _addConvKey.currentContext?.findRenderObject() as RenderBox;

                                      //* Open conversation add window
                                      showModal(ConversationAddWindow(
                                        position:
                                            ContextMenuData(box.localToGlobal(box.size.bottomLeft(const Offset(0, elementSpacing))), true, true),
                                      ));
                                    },
                                    icon: Icon(Icons.chat_bubble, color: theme.colorScheme.onPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                top: false,
                bottom: false,
                child: Obx(() {
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
              ),

              //* Townsquare
              Obx(() {
                return Animate(
                  effects: [
                    ExpandEffect(
                      alignment: Alignment.bottomCenter,
                      duration: 500.ms,
                      curve: scaleAnimationCurve,
                      axis: Axis.vertical,
                    ),
                    FadeEffect(
                      begin: 0,
                      end: 1,
                      duration: 500.ms,
                    ),
                  ],
                  target: Get.find<StatusController>().type.value != 3 &&
                          (Get.find<SettingController>().settings[DataSettings.socialFeatures]!.value.value as bool? ?? false)
                      ? 1
                      : 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: Padding(
                      padding: const EdgeInsets.only(top: defaultSpacing),
                      child: Material(
                        color: Get.find<MessageController>().currentOpenType.value == OpenTabType.townsquare
                            ? Get.theme.colorScheme.primary
                            : Get.theme.colorScheme.onInverseSurface,
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          hoverColor: theme.colorScheme.primary.withAlpha(150),
                          onTap: () => Get.find<MessageController>().openTab(OpenTabType.townsquare),
                          child: Padding(
                            padding: const EdgeInsets.all(elementSpacing2),
                            child: Row(
                              children: [
                                Icon(Icons.location_city, color: Get.theme.colorScheme.onPrimary, size: 35),
                                horizontalSpacing(defaultSpacing),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Townsquare", style: Get.theme.textTheme.labelMedium),
                                        horizontalSpacing(elementSpacing),
                                        Icon(Icons.science, size: 22, color: Get.theme.colorScheme.error),
                                      ],
                                    ),
                                    Text("10 new posts", style: Get.theme.textTheme.bodySmall),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              //* Conversation list
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
                    child: Obx(
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
                                            color: messageController.currentConversation.value == conversation && !isMobileMode()
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(defaultSpacing),
                                              hoverColor: theme.colorScheme.primary.withAlpha(150),
                                              splashColor: theme.hoverColor,
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
                                                                color: theme.colorScheme.onPrimary,
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
                                                                              ? theme.textTheme.labelMedium
                                                                              : theme.textTheme.bodyMedium,
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
                                                                            friend != null
                                                                                ? conversation.dmName
                                                                                : conversation.containerSub.value.name,
                                                                            style: messageController.currentConversation.value == conversation
                                                                                ? theme.textTheme.labelMedium
                                                                                : theme.textTheme.bodyMedium,
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
                                                                        "chat.members".trParams(
                                                                            <String, String>{'count': conversation.members.length.toString()}),

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
                                                                        : Obx(
                                                                            () => Visibility(
                                                                              visible: friend!.status.value != "" &&
                                                                                  friend.statusType.value != statusOffline,
                                                                              child: Text(
                                                                                friend.status.value,
                                                                                style: theme.textTheme.bodySmall,
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
                                                              child: Center(
                                                                  child: Text(min(notifications, 99).toString(), style: theme.textTheme.labelSmall)),
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
                    ),
                  ),
                ),
              ),
              const SidebarProfile()
            ],
          ),
        );
      }),
    );
  }
}
