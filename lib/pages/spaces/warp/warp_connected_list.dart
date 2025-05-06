import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class WarpConnectedList extends StatelessWidget {
  const WarpConnectedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final activeWarps = WarpController.activeWarps.value;
      if (activeWarps.isEmpty) {
        return SizedBox();
      }

      final values = WarpController.activeWarps.value.values.toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(sectionSpacing),
          Text("warp.connected.title".tr, style: Get.textTheme.labelMedium),
          ListView.builder(
            shrinkWrap: true,
            itemCount: values.length,
            itemBuilder: (context, index) {
              // Get the current warp
              final warp = values[index];

              // Render the warp port itself
              return Padding(
                padding: const EdgeInsets.only(top: defaultSpacing),
                child: Material(
                  color: Get.theme.colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(defaultSpacing),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    onTap: () => Clipboard.setData(ClipboardData(text: warp.goalPort.toString())),
                    child: Padding(
                      padding: EdgeInsets.all(defaultSpacing),
                      child: Row(
                        children: [
                          Icon(Icons.cyclone, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(defaultSpacing),
                          Text(
                            "warp.connected.item".trParams({
                              "origin": warp.originPort.toString(),
                              "goal": warp.goalPort.toString(),
                            }),
                            style: Get.textTheme.labelMedium,
                          ),
                          const Spacer(),
                          LoadingIconButton(
                            onTap: () => WarpController.disconnectWarp(warp),
                            extra: 5,
                            icon: Icons.logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
