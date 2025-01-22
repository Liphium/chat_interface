import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class WarpList extends StatelessWidget {
  const WarpList({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (WarpController.warps.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(
            top: sectionSpacing,
            bottom: defaultSpacing,
          ),
          child: Text("warp.list.empty".tr, style: Get.textTheme.labelMedium),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: WarpController.warps.length,
        itemBuilder: (context, index) {
          // Get the current warp
          final warp = WarpController.warps.value[index];

          // Render the warp port itself
          final warpRenderer = Padding(
            padding: const EdgeInsets.only(top: defaultSpacing),
            child: Material(
              color: Get.theme.colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(defaultSpacing),
              child: InkWell(
                borderRadius: BorderRadius.circular(defaultSpacing),
                onTap: () {
                  if (warp.account.id == StatusController.ownAddress) {
                    return;
                  }
                  WarpController.connectToWarp(warp);
                },
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
                      Visibility(
                        visible: warp.account.id != StatusController.ownAddress,
                        child: LoadingIconButton(
                          loading: warp.loading,
                          onTap: () => WarpController.connectToWarp(warp),
                          extra: 5,
                          icon: Icons.add,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          // Check if the account should be rendered
          if (index > 0 && WarpController.warps.value[index - 1].account.id == warp.account.id) {
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
                    Watch(
                      (context) => Text(
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
      );
    });
  }
}
