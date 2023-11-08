import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/space_renderer.dart';
import 'package:chat_interface/pages/chat/sidebar/conversations/conversations_page.dart';
import 'package:chat_interface/pages/chat/sidebar/sharing_hub/join_space_dialog.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SharingHubPage extends StatefulWidget {
  const SharingHubPage({super.key});

  @override
  State<SharingHubPage> createState() => _SharingHubPageState();
}

class _SharingHubPageState extends State<SharingHubPage> {

  final GlobalKey _addKey = GlobalKey();
  final query = "".obs;
  
  final infos = [
    SpaceInfo("", DateTime.now().subtract(Duration(hours: 1)), ["hello", "world"]),
    SpaceInfo("Some space", DateTime.now().subtract(Duration(minutes: 32)), ["max", "mustermann"]),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultSpacing),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildSearchInputSidebar(Get.theme, query, hintText: "sharing.placeholder"),
                horizontalSpacing(defaultSpacing * 0.5),
                SizedBox(
                  key: _addKey,
                  width: 48,
                  height: 48,
                  child: Material(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(defaultSpacing * 1.5),
                    ),
                    color: Get.theme.colorScheme.primary,
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(defaultSpacing),
                      ),
                      onTap: () {
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(defaultSpacing),
                        child: Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final controller = Get.find<StatusController>();
            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.sharedContent.length,
              itemBuilder: (context, index) {
                final container = controller.sharedContent[index];
                if(container is! SpaceConnectionContainer) return const Placeholder();
                return Padding(
                  padding: const EdgeInsets.only(top: defaultSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: container.sender != null,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: elementSpacing),
                          child: Text("sharing.shared".trParams({
                            "name": container.sender?.name ?? "unknown"
                          }), style: Get.theme.textTheme.bodySmall)
                        ),
                      ),
                      Material(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        color: Get.theme.colorScheme.primaryContainer,
                        child: InkWell(
                          onTap: () => Get.dialog(JoinSpaceDialog(container: container)),
                          hoverColor: Get.theme.colorScheme.primary.withAlpha(100),
                          borderRadius: BorderRadius.circular(defaultSpacing),
                          child: SpaceRenderer(container: container)
                        )
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}