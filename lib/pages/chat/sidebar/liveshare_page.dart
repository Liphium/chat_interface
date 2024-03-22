import 'package:chat_interface/controller/conversation/live_share_controller.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveShareWindow extends StatefulWidget {
  const LiveShareWindow({super.key});

  @override
  State<LiveShareWindow> createState() => _LiveShareWindowState();
}

class _LiveShareWindowState extends State<LiveShareWindow> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveShareController>();

    return DialogBase(
      maxWidth: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(defaultSpacing),
            ),
            padding: const EdgeInsets.all(elementSpacing),
            child: Row(
              children: [
                horizontalSpacing(elementSpacing),
                Obx(() {
                  if (controller.currentFile.value == null) {
                    return Icon(
                      Icons.electric_bolt,
                      size: Get.theme.textTheme.labelLarge!.fontSize! * 1.7,
                      color: Get.theme.colorScheme.onPrimary,
                    );
                  }
                  return Icon(
                    getIconForFileName(controller.currentFile.value!.name),
                    size: Get.theme.textTheme.labelLarge!.fontSize! * 1.7,
                    color: Get.theme.colorScheme.onPrimary,
                  );
                }),
                horizontalSpacing(defaultSpacing),
                Obx(() => Text(
                      controller.currentFile.value?.name ?? "No file chosen",
                      style: Get.theme.textTheme.labelLarge,
                    )),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final result = await openFile();
                    if (result == null) {
                      return;
                    }
                    controller.currentFile.value = result;
                  },
                  icon: Icon(
                    Icons.folder,
                    color: Get.theme.colorScheme.onPrimary,
                  ),
                )
              ],
            ),
          ),
          verticalSpacing(defaultSpacing),
          Obx(
            () {
              if (controller.currentFile.value == null) {
                return Container(
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                  ),
                  padding: const EdgeInsets.all(defaultSpacing),
                  child: Text(
                      "Live Share allows you to share large files up to any size with any of your friends on Liphium. Just click the folder icon above to get started.",
                      style: Get.theme.textTheme.labelMedium),
                );
              }

              return const Text("users would now show here or sth");
            },
          ),
          FJElevatedButton(
            onTap: () => {},
            child: Text("Share with self", style: Get.theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
