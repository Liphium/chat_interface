import 'package:chat_interface/pages/chat/sidebar/conversations/conversations_page.dart';
import 'package:chat_interface/pages/chat/sidebar/files/files_page.dart';
import 'package:chat_interface/pages/chat/sidebar/friends/friends_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_icon_button.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/pages/settings/settings_page.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  var map = <int, Widget>{
    0: const ConversationsPage(),
    1: const FriendsPage(),
    2: const FilesPage(),
    3: const SettingsPage(),
  };

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
  var selected = 2.obs;

    //* Sidebar
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onBackground,
      ),

      //* Sidebar content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: RepaintBoundary(
              child: Container(
                color: theme.colorScheme.onBackground,
                padding: const EdgeInsets.all(defaultSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
          
                    //* Conversations
                    SidebarIconButton(
                      icon: Icons.chat_bubble,
                      index: 0,
                      selected: selected,
                      onTap: () {
                        selected.value = 0;
                      },
                      radius: const BorderRadius.only(
                        bottomLeft: Radius.circular(defaultSpacing),
                      )
                    ),
          
                    //* Friends
                    SidebarIconButton(
                      icon: Icons.people,
                      index: 1,
                      selected: selected,
                      onTap: () {
                        selected.value = 1;
                      },
                      radius: const BorderRadius.all(Radius.zero)
                    ),

                    //* Cloud storage
                    SidebarIconButton(
                      icon: Icons.folder,
                      index: 2,
                      selected: selected,
                      onTap: () {
                        selected.value = 2;
                      },
                      radius: const BorderRadius.all(Radius.zero)
                    ),

                    //* Everyone
                    SidebarIconButton(
                      icon: Icons.public,
                      index: 3,
                      selected: selected,
                      onTap: () {
                        selected.value = 3;
                      },
                      radius: const BorderRadius.only(
                        topRight: Radius.circular(defaultSpacing),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ),

          //* Selected tab
          Expanded(
            child: Obx(() => map[selected.value]!),
          ),
          const SidebarProfile()
        ]
      ),
    );
  }
}
