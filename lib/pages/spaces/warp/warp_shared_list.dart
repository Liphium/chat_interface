import 'package:chat_interface/controller/spaces/warp_controller.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class WarpSharedList extends StatelessWidget {
  const WarpSharedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final sharedWarps = WarpController.sharedWarps;
      if (sharedWarps.isEmpty) {
        return SizedBox();
      }

      final values = sharedWarps.values.toList();
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpacing(sectionSpacing),
          Text("warp.shared.title".tr, style: Get.textTheme.labelMedium),
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
                    onTap: () => WarpController.stopWarp(warp),
                    child: Padding(
                      padding: EdgeInsets.all(defaultSpacing),
                      child: Row(
                        children: [
                          Icon(Icons.cyclone, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(defaultSpacing),
                          Text(warp.port.toString(), style: Get.textTheme.labelMedium),
                          const Spacer(),
                          LoadingIconButton(
                            onTap: () => WarpController.stopWarp(warp),
                            extra: 5,
                            icon: Icons.stop_circle,
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
