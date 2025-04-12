import 'package:chat_interface/pages/spaces/warp/warp_connected_list.dart';
import 'package:chat_interface/pages/spaces/warp/warp_create_window.dart';
import 'package:chat_interface/pages/spaces/warp/warp_list.dart';
import 'package:chat_interface/pages/spaces/warp/warp_shared_list.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
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
  Widget build(BuildContext context) {
    return DialogBase(
      title: [Expanded(child: Text("warp.title".tr, style: Get.theme.textTheme.labelLarge, overflow: TextOverflow.ellipsis))],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("warp.desc".tr, style: Get.textTheme.bodyMedium),

          // Render the list of Warps the user is sharing (most important)
          WarpSharedList(),

          // Render the list of Warps connected (first, because it's more important)
          WarpConnectedList(),

          // Render the list of Warps that are available
          WarpList(),
          verticalSpacing(defaultSpacing),

          // Render a button to host a Warp yourself
          FJElevatedButton(
            onTap: () => showModal(WarpCreateWindow()),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_tethering, color: Get.theme.colorScheme.onPrimary),
                  horizontalSpacing(defaultSpacing),
                  Text("warp.share".tr, style: Get.theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
