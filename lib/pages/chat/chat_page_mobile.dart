import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/conversation_list_mobile.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/settings/settings_tab_mobile.dart';
import 'package:chat_interface/pages/status/error/error_container.dart';
import 'package:chat_interface/theme/components/legacy/sidebar_icon_button.dart';
import 'package:chat_interface/theme/ui/profile/own_profile_mobile.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPageMobile extends StatefulWidget {
  final int selected;

  const ChatPageMobile({
    super.key,
    this.selected = 0,
  });

  @override
  State<ChatPageMobile> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageMobile> {
  // The currently selected tab
  final selected = 0.obs;

  // All tabs that can be selected
  final tabs = <int, Widget>{
    0: const ConversationListMobile(),
    1: const OwnProfileMobile(),
    2: const FriendsPage(),
    3: const SettingsTabMobile(),
  };

  @override
  void initState() {
    selected.value = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.onInverseSurface,
      body: PlatformCallback(
        desktop: () {
          Get.off(const ChatPageDesktop());
        },
        child: Column(
          children: [
            Expanded(
              child: Obx(() => tabs[selected.value]!),
            ),
            Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primaryContainer,
              ),
              child: DevicePadding(
                padding: EdgeInsets.symmetric(vertical: defaultSpacing * 1.5),
                child: Column(
                  children: [
                    // Show error from the connection
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: AnimatedErrorContainer(
                        padding: const EdgeInsets.only(
                          bottom: defaultSpacing * 1.5,
                          right: defaultSpacing,
                          left: defaultSpacing,
                        ),
                        message: Get.find<ConnectionController>().error,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SidebarIconButton(
                          onTap: () => selected.value = 0,
                          icon: Icons.chat_bubble,
                          index: 0,
                          selected: selected,
                        ),
                        SidebarIconButton(
                          onTap: () => selected.value = 1,
                          icon: Icons.public,
                          index: 1,
                          selected: selected,
                        ),
                        SidebarIconButton(
                          onTap: () => selected.value = 2,
                          icon: Icons.group,
                          index: 2,
                          selected: selected,
                        ),
                        SidebarIconButton(
                          onTap: () => selected.value = 3,
                          icon: Icons.settings,
                          index: 3,
                          selected: selected,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
