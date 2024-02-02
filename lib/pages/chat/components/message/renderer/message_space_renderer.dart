import 'dart:convert';
import 'dart:math';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/spaces/spaces_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/space_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpaceMessageRenderer extends StatefulWidget {
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const SpaceMessageRenderer({super.key, required this.message, this.self = false, this.last = false, this.sender});

  @override
  State<SpaceMessageRenderer> createState() => _CallMessageRendererState();
}

class _CallMessageRendererState extends State<SpaceMessageRenderer> {
  final loading = false.obs;

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.system();
    sendLog(widget.message.content);
    final container = SpaceConnectionContainer.fromJson(jsonDecode(widget.message.content));

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: elementSpacing,
              horizontal: sectionSpacing,
            ),
            child: Row(
              textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //* Avatar
                Visibility(
                  visible: !widget.last,
                  replacement: const SizedBox(width: 34), //* Show timestamp instead
                  child: Tooltip(message: sender.name, child: UserAvatar(id: sender.id, size: 34)),
                ),
                horizontalSpacing(defaultSpacing),

                //* Message
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: defaultSpacing * 0.5, horizontal: defaultSpacing),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(defaultSpacing),
                        color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.public, color: Get.theme.colorScheme.onPrimary),
                          horizontalSpacing(elementSpacing),
                          Text("chat.space_invite".tr, style: Get.theme.textTheme.labelLarge),
                        ],
                      ),
                    ),
                    verticalSpacing(defaultSpacing),

                    //* Content
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 250,
                      ),
                      child: SpaceRenderer(
                        container: container,
                        clickable: true,
                      ),
                    ),
                  ],
                ),

                horizontalSpacing(defaultSpacing),

                Obx(() {
                  final verified = widget.message.verified.value;
                  return Padding(
                    padding: const EdgeInsets.only(top: elementSpacing),
                    child: Visibility(
                      visible: !verified,
                      child: Tooltip(
                        message: "chat.not.signed".tr,
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget renderMiniAvatars(int amount) {
  final realAmount = min(amount, 5);
  return SizedBox(
    width: sectionSpacing * (realAmount + 2),
    height: sectionSpacing * 1.5,
    child: Stack(
      children: List.generate(realAmount, (index) {
        final positionedWidget = index == realAmount - 1 && amount > 5
            ? Container(
                height: sectionSpacing * 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(sectionSpacing * 1.5),
                  color: Get.theme.colorScheme.background,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: elementSpacing),
                  child: Center(
                    child: Text("+${amount - realAmount + 1}", style: Get.theme.textTheme.labelSmall!.copyWith(color: Get.theme.colorScheme.onPrimary)),
                  ),
                ),
              )
            : SizedBox(
                width: sectionSpacing * 1.5,
                height: sectionSpacing * 1.5,
                child: CircleAvatar(
                  backgroundColor: index % 2 == 0 ? Get.theme.colorScheme.errorContainer : Get.theme.colorScheme.tertiaryContainer,
                  child: Icon(Icons.person, size: sectionSpacing, color: Get.theme.colorScheme.onSurface),
                ),
              );

        return Positioned(
          left: index * sectionSpacing,
          child: positionedWidget,
        );
      }),
    ),
  );
}
