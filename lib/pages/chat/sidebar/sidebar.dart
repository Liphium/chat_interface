import 'package:chat_interface/pages/chat/sidebar/sidebar_button.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/conversations_page.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/friends_page.dart';
import 'package:chat_interface/pages/chat/sidebar/tabs/requests_page.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(right: BorderSide(color: theme.hoverColor)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 5,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Obx(() => Wrap(
            alignment: WrapAlignment.center,
            spacing: defaultSpacing * 0.5,
            runSpacing: defaultSpacing * 0.5,
            children: [
              SidebarButton(
                selected: selected.value == 'chat.all',
                onTap: () {
                  selected.value = 'chat.all';
                },
                label: 'chat.all',
              ),
              SidebarButton(
                selected: selected.value == 'chat.friends',
                onTap: () {
                  selected.value = 'chat.friends';
                },
                label: 'chat.friends',
              ),
              SidebarButton(
                selected: selected.value == 'chat.requests',
                onTap: () {
                  selected.value = 'chat.requests';
                },
                label: 'chat.requests',
              ),
            ],
          )),
        ),
        Expanded(
          child: Obx(() => map[selected.value]!),
        )
      ]),
    );
  }
}
