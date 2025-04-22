import 'package:chat_interface/controller/conversation/sidebar_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_mobile.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/pages/spaces/space_rectangle.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/theme/desktop_widgets.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

/// Get the correct chat page for the current platform
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
  /* We'll need it again some day
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
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: CloseToTray(
        child: SafeArea(
          top: false,
          bottom: false,
          left: false,
          child: PlatformCallback(
            mobile: () {
              Get.off(const ChatPageMobile());
            },
            child: Row(
              children: [
                // Render the sidebar (with an animation when it's hidden/shown)
                SelectionContainer.disabled(
                  child: Watch(
                    (ctx) => Animate(
                      effects: [
                        ExpandEffect(
                          curve: Curves.easeInOut,
                          duration: 250.ms,
                          axis: Axis.horizontal,
                          alignment: Alignment.centerRight,
                        ),
                        FadeEffect(duration: 250.ms),
                      ],
                      onInit: (ac) => ac.value = SidebarController.hideSidebar.value ? 0 : 1,
                      target: SidebarController.hideSidebar.value ? 0 : 1,
                      child: SizedBox(width: 350, child: Sidebar()),
                    ),
                  ),
                ),

                // Render the current sidebar tab
                Expanded(child: Watch((ctx) => SidebarController.currentOpenTab.value.build(ctx))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Default sidebar tab when the app is started
class DefaultSidebarTab extends SidebarTab {
  DefaultSidebarTab() : super(SidebarTabType.none, "def");

  @override
  Widget build(BuildContext context) {
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
}

/// Sidebar tab for a conversation
class ConversationSidebarTab extends SidebarTab {
  final ConversationMessageProvider provider;

  ConversationSidebarTab(this.provider)
    : super(SidebarTabType.conversation, "conv-${provider.conversation.id.encode()}");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Render the message bar for desktop
        DevicePadding(
          top: true,
          padding: const EdgeInsets.all(0),
          child: MessageBar(conversation: provider.conversation, provider: provider),
        ),

        // Render the message feed + search sidebar
        Expanded(
          child: Row(
            children: [
              // Render the chat messages
              Expanded(child: MessageFeed()),

              // Render the search window
              SelectionContainer.disabled(
                child: Watch(
                  (ctx) => Animate(
                    key: ValueKey("rsa-${provider.conversation.id.encode()}"),
                    effects: [
                      ExpandEffect(
                        curve: Curves.easeInOut,
                        duration: 250.ms,
                        axis: Axis.horizontal,
                        alignment: Alignment.centerLeft,
                      ),
                      FadeEffect(duration: 250.ms),
                    ],
                    onInit: (ac) => ac.value = SidebarController.rightSidebar[key] != null ? 1 : 0,
                    target: SidebarController.rightSidebar[key] != null ? 1 : 0,
                    child: SizedBox(width: 350, child: SidebarController.rightSidebar[key]?.build(ctx)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sidebar tab for the Space the user is currently in
class SpaceSidebarTab extends SidebarTab {
  SpaceSidebarTab() : super(SidebarTabType.space, "space");

  @override
  Widget build(BuildContext context) {
    return const SpaceRectangle();
  }
}
