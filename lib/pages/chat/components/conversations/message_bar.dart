import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_info_window.dart';
import 'package:chat_interface/pages/settings/data/settings_manager.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageBar extends StatefulWidget {
  final Conversation conversation;

  const MessageBar({super.key, required this.conversation});

  @override
  State<MessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final callLoading = false.obs;
  final GlobalKey _groupAddKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingController>();

    if (widget.conversation.borked) {
      return Material(
        color: Get.theme.colorScheme.onBackground,
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Icon(Icons.person_off, size: 30, color: Theme.of(context).colorScheme.error),
              horizontalSpacing(defaultSpacing),
              Text("friend.removed".tr, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Get.theme.colorScheme.onBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //* Conversation label
            Row(
              children: [
                Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
                horizontalSpacing(defaultSpacing),
                Text(widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),

            //* Conversation actions
            Row(
              children: [
                if (Get.find<SpacesController>().inSpace.value)
                  LoadingIconButton(
                    icon: Icons.add_call,
                    iconSize: 27,
                    loading: callLoading,
                    tooltip: "chat.add_space".tr,
                    onTap: () {
                      final controller = Get.find<SpacesController>();
                      controller.inviteToCall(Get.find<MessageController>().selectedConversation.value.id);
                    },
                  ),

                LoadingIconButton(
                  icon: Icons.call,
                  iconSize: 27,
                  loading: callLoading,
                  tooltip: "chat.start_space".tr,
                  onTap: () {
                    final controller = Get.find<SpacesController>();
                    controller.createAndConnect(Get.find<MessageController>().selectedConversation.value.id);
                  },
                ),

                horizontalSpacing(elementSpacing),

                //* Invite people
                LoadingIconButton(
                  key: _groupAddKey,
                  icon: Icons.group_add,
                  iconSize: 27,
                  loading: callLoading,
                  onTap: () {
                    // Calculate position of the window
                    final RenderBox box = _groupAddKey.currentContext?.findRenderObject() as RenderBox;
                    final Offset globalPos = box.localToGlobal(box.size.bottomRight(const Offset(0, elementSpacing)));
                    final windowWidth = Get.mediaQuery.size.width;
                    final position = Offset(windowWidth - globalPos.dx, globalPos.dy);

                    // Open conversation add window based on the type of conversation
                    if (widget.conversation.isGroup) {
                      // Get all friends in conversation
                      var initial = <Friend>[];
                      for (var member in widget.conversation.members.values) {
                        if (member.account == StatusController.ownAccountId) {
                          continue;
                        }
                        final friend = member.getFriend();
                        if (friend.unknown) {
                          return;
                        }
                        initial.add(friend);
                      }
                      Get.dialog(ConversationAddWindow(
                        title: "conversations.add",
                        action: "add",
                        nameField: false,
                        position: ContextMenuData(position, true, false),
                        initial: initial,
                        onDone: (friends, name) async {
                          final finalList = <Friend>[];
                          for (var friend in friends) {
                            if (!initial.any((element) => element.id == friend.id)) {
                              finalList.add(friend);
                            }
                          }
                          sendLog(finalList);

                          // Add the people to the conversation
                          for (var friend in finalList) {
                            final res = await addToConversation(widget.conversation, friend);
                            if (!res) {
                              showErrorPopup("error", "server.error");
                              return null;
                            }
                          }

                          return null;
                        },
                      ));
                    } else {
                      // Get the friend and open the window
                      final friend = widget.conversation.members.values.firstWhere((element) => element.account != StatusController.ownAccountId).getFriend();
                      if (friend.unknown) {
                        return;
                      }
                      Get.dialog(ConversationAddWindow(
                        title: "conversations.add.create",
                        position: ContextMenuData(position, true, false),
                        initial: [friend],
                      ));
                    }
                  },
                ),
                horizontalSpacing(elementSpacing),

                //* Conversation info
                LoadingIconButton(
                  icon: Icons.info,
                  iconSize: 27,
                  onTap: () {
                    Get.dialog(ConversationInfoWindow(conversation: widget.conversation));
                  },
                ),

                horizontalSpacing(elementSpacing),
                Visibility(
                  visible: widget.conversation.isGroup,
                  child: Obx(
                    () => IconButton(
                      iconSize: 27,
                      icon: Icon(Icons.group,
                          color: controller.settings[AppSettings.showGroupMembers]!.value.value
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface),
                      onPressed: () {
                        controller.settings[AppSettings.showGroupMembers]!.setValue(!controller.settings[AppSettings.showGroupMembers]!.value.value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
