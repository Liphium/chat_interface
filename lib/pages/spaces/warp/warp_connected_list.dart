import 'package:chat_interface/controller/conversation/spaces/warp_controller.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WarpConnectedList extends StatelessWidget {
  const WarpConnectedList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WarpController>();
    return Obx(() {
      if (controller.activeWarps.isEmpty) {
        return SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(sectionSpacing),
          Text("warp.connected.title".tr, style: Get.textTheme.labelMedium),
          ListView.builder(
            shrinkWrap: true,
            itemCount: controller.activeWarps.length,
            itemBuilder: (context, index) {
              // Get the current warp
              final warp = controller.activeWarps[index];

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

              // Render the header for who's sharing the Warp
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
                            "warp.list.sharing".trParams({
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
          ),
        ],
      );
    });
  }
}
