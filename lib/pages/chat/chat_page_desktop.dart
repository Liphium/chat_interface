import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_mobile.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/conversation_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/pages/spaces/call_rectangle.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget getChatPage() {
  if (isMobileMode()) {
    return const ChatPageMobile();
  }

  return const ChatPageDesktop();
}

class ChatPageDesktop extends StatefulWidget {
  const ChatPageDesktop({super.key});

  @override
  State<ChatPageDesktop> createState() => _ChatPageDesktopState();
}

class _ChatPageDesktopState extends State<ChatPageDesktop> {
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

  bool optionsOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: SafeArea(
        top: false,
        bottom: false,
        left: false,
        child: SelectionArea(
          key: const ValueKey("selection_area"),
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

            if (!optionsOpened) {
              optionsOpened = true;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                await Get.dialog(MessageOptionsWindow(
                  data: menuData,
                  self: controller.hoveredMessage!.senderAccount == StatusController.ownAccountId,
                  message: controller.hoveredMessage!,
                  extra: extraButtons.isEmpty ? null : extraButtons,
                ));
                optionsOpened = false;
              });
            }
            return const SizedBox();
          },
          child: PlatformCallback(
            mobile: () {
              final controller = Get.find<MessageController>();
              if (controller.currentConversation.value != null) {
                Get.off(const ChatPageMobile());
                Get.to(ConversationPage(conversation: controller.currentConversation.value!));
              } else {
                Get.off(const ChatPageMobile());
              }
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
                  child: Obx(
                    () {
                      // Check if a space is selected (show the page if it is)
                      final controller = Get.find<MessageController>();
                      switch (controller.currentOpenType.value) {
                        case OpenTabType.conversation:
                          if (controller.currentConversation.value == null) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('app.title'.tr, style: Theme.of(context).textTheme.headlineMedium),
                                verticalSpacing(sectionSpacing),
                                Text('app.welcome'.tr, style: Theme.of(context).textTheme.bodyLarge),
                                verticalSpacing(elementSpacing),
                                Text('app.build'.trParams({"build": "Alpha"}), style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            );
                          }

                          return MessageFeed(conversation: controller.currentConversation.value!);
                        default:
                          return const CallRectangle();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
