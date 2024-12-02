import 'package:chat_interface/controller/conversation/spaces/warp_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WarpManagerWindow extends StatefulWidget {
  const WarpManagerWindow({super.key});

  @override
  State<WarpManagerWindow> createState() => _WarpManagerWindowState();
}

class _WarpManagerWindowState extends State<WarpManagerWindow> {
  @override
  void initState() {
    Get.find<WarpController>().startScanning();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WarpController>();

    return DialogBase(
      title: [
        Expanded(
          child: Text(
            "spaces.warp.title".tr,
            style: Get.theme.textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        horizontalSpacing(defaultSpacing),
        FJElevatedButton(
          onTap: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_tethering, color: Get.theme.colorScheme.onPrimary),
              horizontalSpacing(defaultSpacing),
              Text("spaces.warp.share".tr, style: Get.theme.textTheme.labelMedium),
            ],
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("spaces.warp.desc".tr, style: Get.textTheme.bodyMedium),
          Obx(() {
            if (controller.warps.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: Text("spaces.warp.empty".tr, style: Get.textTheme.labelMedium),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: controller.warps.length,
              itemBuilder: (context, index) {
                // Get the current warp
                final warp = controller.warps[index];

                // Render the warp port itself
                final warpRenderer = Padding(
                  padding: const EdgeInsets.only(top: defaultSpacing),
                  child: Material(
                    color: Get.theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      onTap: () => {},
                      child: Padding(
                        padding: EdgeInsets.all(defaultSpacing),
                        child: Row(
                          children: [
                            Icon(Icons.cyclone, color: Get.theme.colorScheme.onPrimary),
                            horizontalSpacing(defaultSpacing),
                            Text(
                              warp.port.toString(),
                              style: Get.textTheme.labelMedium,
                            ),
                            const Spacer(),
                            LoadingIconButton(
                              onTap: () {},
                              extra: 5,
                              icon: Icons.add,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                // Check if the account should be rendered
                if (index > 0 && controller.warps[index - 1].account.id == warp.account.id) {
                  return warpRenderer;
                }

                return Padding(
                  padding: const EdgeInsets.only(top: sectionSpacing),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          UserAvatar(id: warp.account.id, size: 35),
                          horizontalSpacing(defaultSpacing),
                          Obx(
                            () => Text(
                              "spaces.warp.item.account".trParams({
                                "name": warp.account.displayName.value,
                              }),
                              style: Get.theme.textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                      warpRenderer,
                    ],
                  ),
                );
              },
            );
          })
        ],
      ),
    );
  }
}
