import 'package:chat_interface/controller/current/notification_controller.dart' as nc;
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarProfile extends StatefulWidget {
  const SidebarProfile({super.key});

  @override
  State<SidebarProfile> createState() => _SidebarProfileState();
}

class _SidebarProfileState extends State<SidebarProfile> {
  @override
  Widget build(BuildContext context) {
    StatusController controller = Get.find();
    ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => {},
        splashColor: theme.hoverColor.withAlpha(7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing * 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 35,
                    ),
                    horizontalSpacing(defaultSpacing),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.name.value, style: theme.textTheme.titleMedium,),
                        Text("#${controller.tag.value}", style: theme.textTheme.bodyMedium,),
                      ],
                    ),
                  ],
                )
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.mic_off, color: Colors.white),
                  ),
                  horizontalSpacing(defaultSpacing * 0.5),
                  IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.volume_off, color: Colors.white),
                  ),
                  horizontalSpacing(defaultSpacing * 0.5),
                  IconButton(
                    onPressed: () => Get.find<nc.NotificationController>().notifications.add(nc.Notification(message: "Hello World, Friends!")),
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}