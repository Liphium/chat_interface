import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/zap_share_controller.dart';
import 'package:chat_interface/theme/components/forms/fj_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

class ZapShareWindow extends StatelessWidget {
  final Conversation conversation;
  final ContextMenuData data;

  const ZapShareWindow({super.key, required this.data, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      title: const [],
      position: data,
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
                      Watch((ctx) => Text("${ZapShareController.step.value} ", style: Get.theme.textTheme.labelLarge)),
                      Watch(
                        (ctx) => Text(
                          "(${ZapShareController.currentPart.value}/${ZapShareController.endPart})",
                          style: Get.theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  verticalSpacing(defaultSpacing),
                  FJElevatedButton(
                    onTap: () {
                      ZapShareController.cancel();
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
                  ),
                ],
              ),
              const Spacer(),
              Watch(
                (ctx) => CircularProgressIndicator(
                  backgroundColor: Get.theme.colorScheme.primary,
                  value: ZapShareController.waiting.value ? null : ZapShareController.progress.value,
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
