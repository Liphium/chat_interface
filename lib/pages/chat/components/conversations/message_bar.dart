import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/conversation/message_search_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/controller/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database_entities.dart' as model;
import 'package:chat_interface/pages/chat/components/conversations/conversation_edit_window.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/pages/status/error/offline_hider.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/conversation_add_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liphium_bridge/liphium_bridge.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MessageBar extends StatefulWidget {
  final Conversation conversation;
  final MessageProvider provider;

  const MessageBar({super.key, required this.conversation, required this.provider});

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
            // Make sure the arrow doesn't shift the conversation label into the middle
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show a hide sidebar icon for more focus on the current conversation
                Obx(
                  () => LoadingIconButton(
                    onTap: () => Get.find<MessageController>().toggleSidebar(),
                    icon: Get.find<MessageController>().hideSidebar.value ? Icons.arrow_forward : Icons.arrow_back,
                  ),
                ),
                horizontalSpacing(elementSpacing),

                // Render the label of the conversation
                Material(
                  key: _infoKey,
                  color: Get.theme.colorScheme.onInverseSurface,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    hoverColor: Get.theme.hoverColor,
                    onTap: () {
                      showModal(ConversationInfoWindow(
                        conversation: widget.conversation,
                        position: ContextMenuData.fromKey(_infoKey, below: true),
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
                          Text(widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            //* Conversation actions
            Obx(() {
              final error = widget.conversation.error.value != null;

              return Row(
                children: [
                  // Put all online actions in a separate row to make them be hidden when not connected
                  OfflineHider(
                    axis: Axis.horizontal,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        //* Zap share
                        if (widget.conversation.type == model.ConversationType.directMessage && isDirectorySupported && !error)
                          Stack(
                            key: _zapShareKey,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await zapShareController.openWindow(widget.conversation, ContextMenuData.fromKey(_zapShareKey, below: true));
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
                                        value: zapShareController.waiting.value ? null : zapShareController.progress.value.clamp(0, 1),
                                        strokeWidth: 3,
                                        valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.onPrimary),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),

                        if (Get.find<SpacesController>().inSpace.value && areSpacesSupported && !error)
                          LoadingIconButton(
                            icon: Icons.forward_to_inbox,
                            iconSize: 27,
                            loading: callLoading,
                            tooltip: "chat.invite_to_space".tr,
                            onTap: () {
                              final controller = Get.find<SpacesController>();
                              controller.inviteToCall(widget.provider);
                            },
                          ),

                        // Only show launch button in case supported
                        if (areSpacesSupported && !error)
                          LoadingIconButton(
                            icon: Icons.rocket_launch,
                            iconSize: 27,
                            loading: callLoading,
                            tooltip: "chat.start_space".tr,
                            onTap: () {
                              final controller = Get.find<SpacesController>();
                              controller.createAndConnect(widget.provider);
                            },
                          ),

                        // Give the user the ability to add people to a conversation
                        if (!error)
                          ConversationAddButton(
                            conversation: widget.conversation,
                            loading: callLoading,
                          ),

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
                                controller.settings[AppSettings.showGroupMembers]!
                                    .setValue(!controller.settings[AppSettings.showGroupMembers]!.value.value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search the entire conversation
                  Obx(
                    () => IconButton(
                      iconSize: 27,
                      icon: Icon(Icons.search,
                          color: Get.find<MessageController>().showSearch.value
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface),
                      onPressed: () {
                        Get.find<MessageController>().toggleSearchView();
                        if (Get.find<MessageController>().showSearch.value) {
                          Get.find<MessageSearchController>().currentFocus!.requestFocus();
                        }
                      },
                    ),
                  ),

                  LoadingIconButton(
                    icon: Icons.help,
                    iconSize: 27,
                    tooltip: "help".tr,
                    onTap: () {
                      launchUrlString(Constants.docsBase);
                    },
                  ),
                ],
              );
            }),
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
            if (member.address == StatusController.ownAddress) {
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
                  showErrorPopup("error", "server.error".tr);
                  return null;
                }
              }

              return null;
            },
          ));
        } else {
          // Get the friend and open the window
          final friend = widget.conversation.members.values.firstWhere((element) => element.address != StatusController.ownAddress).getFriend();
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
