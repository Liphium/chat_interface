import 'package:chat_interface/pages/chat/chat_page_desktop.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar.dart';
import 'package:chat_interface/pages/settings/settings_page_mobile.dart';
import 'package:chat_interface/theme/components/legacy/sidebar_icon_button.dart';
import 'package:chat_interface/theme/ui/profile/own_profile_mobile.dart';
import 'package:chat_interface/util/platform_callback.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPageMobile extends StatefulWidget {
  const ChatPageMobile({super.key});

  @override
  State<ChatPageMobile> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageMobile> {
  final selected = 0.obs;

  final tabs = <int, Widget>{
    0: const Sidebar(),
    1: const OwnProfileMobile(),
    2: const FriendsPage(),
    3: const SettingsPageMobile(),
  };

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
              padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 1.5),
              child: Row(
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
            )
          ],
        ),
      ),
    );
  }
}
