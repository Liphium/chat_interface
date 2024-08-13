import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/app/instance_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeveloperWindow extends StatefulWidget {
  const DeveloperWindow({super.key});

  @override
  State<DeveloperWindow> createState() => _DeveloperWindowState();
}

class _DeveloperWindowState extends State<DeveloperWindow> {
  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text("Developer info", style: Get.theme.textTheme.labelLarge),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current instance: $currentInstance", style: Get.textTheme.bodyMedium),
          verticalSpacing(elementSpacing),
          Text("Instance domain: ${connector.url ?? "Not connected"}", style: Get.textTheme.bodyMedium),
          verticalSpacing(elementSpacing),
          Text("Current account: ${StatusController.ownAccountId}", style: Get.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all conversations (local)",
            onTap: () => db.conversation.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all members (local)",
            onTap: () => db.member.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all friends (local)",
            onTap: () => db.friend.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all library entries (local)",
            onTap: () => db.libraryEntry.deleteAll(),
            loading: false.obs,
          ),
        ],
      ),
    );
  }
}
