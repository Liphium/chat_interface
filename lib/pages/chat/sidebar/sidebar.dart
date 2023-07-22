import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/pages/chat/sidebar/sidebar_profile.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/conversations/conversations_page.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/friends/friends_page.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/requests/requests_page.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  var map = <String, Widget>{
    'chat.all': const ConversationsPage(),
    'chat.friends': const FriendsPage(),
    'chat.requests': const RequestsPage(),
  };

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    var selected = 'chat.all'.obs;

    //* Sidebar
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
      ),

      //* Sidebar content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultSpacing),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: defaultSpacing * 0.5,
                  runSpacing: defaultSpacing * 0.5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
          
                    //* Conversations
                    SidebarButton(
                      selected: selected,
                      onTap: () {
                        selected.value = 'chat.all';
                      },
                      label: 'chat.all',
                      radius: const BorderRadius.only(
                        bottomLeft: Radius.circular(defaultSpacing),
                      )
                    ),
          
                    //* Friends
                    SidebarButton(
                      selected: selected,
                      onTap: () {
                        selected.value = 'chat.friends';
                      },
                      label: 'chat.friends',
                      radius: const BorderRadius.all(Radius.zero)
                    ),
          
                    //* Requests
                    SidebarButton(
                      selected: selected,
                      onTap: () {
                        selected.value = 'chat.requests';
                      },
                      label: 'chat.requests',
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
