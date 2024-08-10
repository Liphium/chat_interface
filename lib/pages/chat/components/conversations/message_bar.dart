import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/pages/chat/components/conversations/zap_share_window.dart';
import 'package:chat_interface/pages/chat/conversation_info_page.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
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
  final GlobalKey _infoKey = GlobalKey(), _zapShareKey = GlobalKey();
  final callLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final zapShareController = Get.find<ZapShareController>();
    final controller = Get.find<SettingController>();

    if (widget.conversation.borked) {
      return Material(
        color: Get.theme.colorScheme.onInverseSurface,
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
      color: Get.theme.colorScheme.onInverseSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //* Conversation label
            Material(
              key: _infoKey,
              color: Get.theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: InkWell(
                borderRadius: BorderRadius.circular(defaultSpacing),
                hoverColor: Get.theme.hoverColor,
                onTap: () {
                  showModal(ConversationInfoPage(
                    conversation: widget.conversation,
                    position: ContextMenuData.fromKey(_infoKey, below: true),
                    showMembers: false,
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: elementSpacing,
                    horizontal: defaultSpacing,
                  ),
                  child: Row(
                    children: [
                      Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
                      horizontalSpacing(defaultSpacing),
                      Text(widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ),

            //* Conversation actions
            Row(
              children: [
                //* Zap share
                if (widget.conversation.type == model.ConversationType.directMessage)
                  Stack(
                    key: _zapShareKey,
                    children: [
                      IconButton(
                        onPressed: () async {
                          zapShareController.openWindow(widget.conversation, ContextMenuData.fromKey(_zapShareKey, below: true));
                        },
                        icon: Icon(Icons.electric_bolt, color: Get.theme.colorScheme.onPrimary),
                        tooltip: "chat.zapshare".tr,
                      ),
                      IgnorePointer(
                        child: SizedBox(
                          width: 48 - defaultSpacing,
                          height: 48 - defaultSpacing,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Obx(
                              () => CircularProgressIndicator(
                                value: zapShareController.waiting.value ? null : zapShareController.progress.value,
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.onPrimary),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                if (Get.find<SpacesController>().inSpace.value)
                  LoadingIconButton(
                    icon: Icons.add_call,
                    iconSize: 27,
                    loading: callLoading,
                    tooltip: "chat.add_space".tr,
                    onTap: () {
                      final controller = Get.find<SpacesController>();
                      controller.inviteToCall(widget.conversation.id);
                    },
                  ),

                LoadingIconButton(
                  icon: Icons.call,
                  iconSize: 27,
                  loading: callLoading,
                  tooltip: "chat.start_space".tr,
                  onTap: () {
                    final controller = Get.find<SpacesController>();
                    controller.createAndConnect(widget.conversation.id);
                  },
                ),

                //* Invite people
                ConversationAddButton(
                  conversation: widget.conversation,
                  loading: callLoading,
                ),
                horizontalSpacing(elementSpacing),

                Visibility(
                  visible: widget.conversation.isGroup,
                  child: Obx(
                    () => IconButton(
                      iconSize: 27,
                      icon:
                          Icon(Icons.group, color: controller.settings[AppSettings.showGroupMembers]!.value.value ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
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

class ConversationAddButton extends StatefulWidget {
  final Conversation conversation;
  final RxBool loading;

  const ConversationAddButton({super.key, required this.conversation, required this.loading});

  @override
  State<ConversationAddButton> createState() => _ConversationAddButtonState();
}

class _ConversationAddButtonState extends State<ConversationAddButton> {
  final GlobalKey _groupAddKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return LoadingIconButton(
      key: _groupAddKey,
      icon: Icons.group_add,
      iconSize: 27,
      loading: widget.loading,
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
          showModal(ConversationAddWindow(
            title: "conversations.add.create",
            position: ContextMenuData(position, true, false),
            initial: [friend],
          ));
        }
      },
    );
  }
}
