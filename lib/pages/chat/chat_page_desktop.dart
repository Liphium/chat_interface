import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_mobile.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_bar.dart';
import 'package:chat_interface/pages/chat/components/conversations/message_search_window.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/components/townsquare/townsquare_page.dart';
import 'package:chat_interface/pages/chat/messages_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/pages/spaces/space_rectangle.dart';
import 'package:chat_interface/theme/desktop_widgets.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final controller = Get.find<MessageController>();

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.inverseSurface,
      body: CloseToTray(
        child: SafeArea(
          top: false,
          bottom: false,
          left: false,
          child: PlatformCallback(
            mobile: () {
              final controller = Get.find<MessageController>();
              if (controller.currentProvider.value != null) {
                Get.off(const ChatPageMobile());
                Get.to(MessagesPageMobile(provider: controller.currentProvider.value!));
              } else {
                Get.off(const ChatPageMobile());
              }
            },
            child: Row(
              children: [
                // Render the sidebar (with an animation when it's hidden/shown)
                SelectionContainer.disabled(
                  child: Obx(
                    () => Animate(
                      effects: [
                        ExpandEffect(
                          curve: Curves.easeInOut,
                          duration: 250.ms,
                          axis: Axis.horizontal,
                          alignment: Alignment.centerRight,
                        ),
                        FadeEffect(
                          duration: 250.ms,
                        )
                      ],
                      onInit: (ac) => ac.value = controller.hideSidebar.value ? 0 : 1,
                      target: controller.hideSidebar.value ? 0 : 1,
                      child: SizedBox(
                        width: 350,
                        child: Sidebar(),
                      ),
                    ),
                  ),
                ),

                // Render the conversation/space/other stuff
                Expanded(
                  child: Obx(
                    () {
                      // Check if a space is selected (show the page if it is)
                      final controller = Get.find<MessageController>();
                      switch (controller.currentOpenType.value) {
                        case OpenTabType.townsquare:
                          return const TownsquarePage();
                        case OpenTabType.conversation:
                          if (controller.currentProvider.value == null) {
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

                          return Column(
                            children: [
                              // Render the message bar for desktop
                              DevicePadding(
                                top: true,
                                padding: const EdgeInsets.all(0),
                                child: MessageBar(
                                  conversation: controller.currentProvider.value!.conversation,
                                  provider: controller.currentProvider.value!,
                                ),
                              ),

                              // Render the message feed + search sidebar
                              Expanded(
                                child: Row(
                                  children: [
                                    // Render the chat messages
                                    Expanded(
                                      child: MessageFeed(),
                                    ),

                                    // Render the search window
                                    SelectionContainer.disabled(
                                      child: Obx(
                                        () => Animate(
                                          effects: [
                                            ExpandEffect(
                                              curve: Curves.easeInOut,
                                              duration: 250.ms,
                                              axis: Axis.horizontal,
                                              alignment: Alignment.centerLeft,
                                            ),
                                            FadeEffect(
                                              duration: 250.ms,
                                            )
                                          ],
                                          onInit: (ac) => ac.value = controller.showSearch.value ? 1 : 0,
                                          target: controller.showSearch.value ? 1 : 0,
                                          child: SizedBox(
                                            width: 350,
                                            child: MessageSearchWindow(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        default:
                          return const SpaceRectangle();
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
