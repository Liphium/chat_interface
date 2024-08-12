import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZapShareWindow extends StatefulWidget {
  final Conversation conversation;
  final ContextMenuData data;

  const ZapShareWindow({
    super.key,
    required this.data,
    required this.conversation,
  });

  @override
  State<ZapShareWindow> createState() => _ZapShareWindowState();
}

class _ZapShareWindowState extends State<ZapShareWindow> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ZapShareController>();

    return SlidingWindowBase(
      title: const [],
      position: widget.data,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Obx(() => Text("${controller.step.value} ", style: Get.theme.textTheme.labelLarge)),
                      Obx(() => Text("(${controller.currentPart.value}/${controller.endPart})", style: Get.theme.textTheme.bodyLarge)),
                    ],
                  ),
                  verticalSpacing(defaultSpacing),
                  FJElevatedButton(
                    onTap: () {
                      controller.cancel();
                      Get.back();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stop_circle, color: Get.theme.colorScheme.onPrimary),
                        horizontalSpacing(defaultSpacing),
                        Text("Stop file transfer", style: Get.theme.textTheme.labelLarge),
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),
              Obx(
                () => CircularProgressIndicator(
                  backgroundColor: Get.theme.colorScheme.primary,
                  value: controller.waiting.value ? null : controller.progress.value,
                  valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
