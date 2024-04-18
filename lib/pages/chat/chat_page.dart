import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/townsquare_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/components/townsquare/townsquare_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _buttonIcons = <ContextMenuButtonType, IconData>{
    ContextMenuButtonType.cut: Icons.content_cut,
    ContextMenuButtonType.copy: Icons.content_copy,
    ContextMenuButtonType.paste: Icons.content_paste,
    ContextMenuButtonType.selectAll: Icons.select_all,
    ContextMenuButtonType.delete: Icons.delete,
    ContextMenuButtonType.lookUp: Icons.search,
    ContextMenuButtonType.searchWeb: Icons.search,
    ContextMenuButtonType.share: Icons.share,
    ContextMenuButtonType.liveTextInput: Icons.keyboard,
    ContextMenuButtonType.custom: Icons.extension,
  };

  @override
  Widget build(BuildContext context) {
    final TownsquareController tsController = Get.find();
    final MessageController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SelectionArea(
        contextMenuBuilder: (context, selectableRegionState) {
          final controller = Get.find<MessageController>();

          // Don't show the context menu when there is no message hovered (we may wanna add like profile context menus and stuff)
          if (controller.hoveredMessage == null) {
            selectableRegionState.hideToolbar();
            return const SizedBox.shrink();
          }
          final menuData = ContextMenuData.fromPosition(selectableRegionState.contextMenuAnchors.primaryAnchor);

          // Add all the normal buttons to the context menu
          final extraButtons = <ProfileButton>[];
          for (var menuButton in selectableRegionState.contextMenuButtonItems) {
            if (menuButton.type == ContextMenuButtonType.selectAll) {
              continue;
            }
            extraButtons.add(ProfileButton(
              icon: _buttonIcons[menuButton.type]!,
              label: "context_menu.${menuButton.type.name}".tr,
              onTap: menuButton.onPressed ?? () => sendLog("no function found for ${menuButton.type.toString()}"),
              loading: false.obs,
            ));
          }

          // Show the context menu
          return MessageOptionsWindow(
            data: menuData,
            self: controller.hoveredMessage!.senderAccount == StatusController.ownAccountId,
            message: controller.hoveredMessage!,
            extra: extraButtons.isEmpty ? null : extraButtons,
          );
        },
        child: Row(
          children: [
            const SelectionContainer.disabled(
              child: SizedBox(
                width: 350,
                child: Sidebar(),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (tsController.inView.value) {
                  return const TownsquareFeed();
                }
                return MessageFeed(conversation: controller.selectedConversation.value);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
