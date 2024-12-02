import 'package:chat_interface/controller/conversation/spaces/warp_controller.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
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
    return DialogBase(
      title: [
        Expanded(
            child: Text(
          "space.warp.title".tr,
          style: Get.theme.textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
        )),
        Obx(
          () => Visibility(
            visible: Get.find<WarpController>().scanning.value,
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Get.theme.colorScheme.onPrimary,
              ),
            ),
          ),
        )
      ],
      child: Column(
        children: [],
      ),
    );
  }
}
