import 'package:chat_interface/pages/status/setup/server_setup.dart';
import 'package:chat_interface/theme/components/transitions/transition_controller.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServerSelectorContainer extends StatelessWidget {
  final Widget Function() pageToGoBack;

  const ServerSelectorContainer({super.key, required this.pageToGoBack});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "connecting_container",
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultSpacing * 1.5),
          color: Get.theme.colorScheme.onInverseSurface,
        ),
        width: 370,
        child: Padding(
          padding: const EdgeInsets.all(sectionSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "server.choose.server.connecting".tr,
                  style: Get.theme.textTheme.bodyMedium,
                ),
              ),
              verticalSpacing(defaultSpacing),
              Material(
                color: Get.theme.colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(defaultSpacing),
                child: InkWell(
                  onTap: () => Get.find<TransitionController>().modelTransition(ServerSelectorPage(nextPage: pageToGoBack.call())),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
