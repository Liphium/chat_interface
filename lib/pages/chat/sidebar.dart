import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: defaultSpacing * 0.5,
              runSpacing: defaultSpacing * 0.5,
              children: [
                ElevatedButton(
                  onPressed: () => {}, 
                  child: Text('chat.conv'.tr)
                ),
                ElevatedButton(
                  onPressed: () => {}, 
                  child: Text('chat.groups'.tr)
                ),
                ElevatedButton(
                  onPressed: () => {}, 
                  child: Text('chat.requests'.tr)
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    [Icons.person, Icons.group, Icons.person_2, Icons.person_4, Icons.person_3][index],
                    size: 55
                  ),
                  title: Text('chat.@type'.trParams(
                    {'type': ['title', 'group', 'title', 'title', 'title'][index]}
                  )),
                  subtitle: Text('chat.lastMessage'.tr),
                  trailing: index <= 1 ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ) : null,
                );
              },
            ),
          )
        ]
      ),
    );
  }
}