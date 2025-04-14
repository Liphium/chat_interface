import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/pages/status/setup/setup_manager.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServerSelectorContainer extends StatelessWidget {
  final Function() onSelected;

  const ServerSelectorContainer({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Get.theme.colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(defaultSpacing),
      child: InkWell(
        onTap:
            () => setupManager.controller!.transitionTo(ServerSelectorPage(onSelected: onSelected)),
        borderRadius: BorderRadius.circular(defaultSpacing),
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Icon(Icons.public, color: Get.theme.colorScheme.onPrimary),
              horizontalSpacing(defaultSpacing),
              Expanded(
                child: Text(
                  basePath.replaceAll("/v1", ""),
                  style: Get.theme.textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              horizontalSpacing(defaultSpacing),
              Icon(Icons.edit, color: Get.theme.colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
