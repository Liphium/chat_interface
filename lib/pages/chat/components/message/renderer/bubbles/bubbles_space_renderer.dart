import 'dart:convert';

import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/services/spaces/space_container.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/space_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubblesSpaceMessageRenderer extends StatefulWidget {
  final Message message;
  final MessageProvider provider;
  final bool self;
  final bool last;
  final Friend? sender;
  final bool mobileLayout;

  const BubblesSpaceMessageRenderer({
    super.key,
    required this.message,
    required this.provider,
    this.self = false,
    this.last = false,
    this.sender,
    this.mobileLayout = false,
  });

  @override
  State<BubblesSpaceMessageRenderer> createState() => _CallMessageRendererState();
}

class _CallMessageRendererState extends State<BubblesSpaceMessageRenderer> {
  final loading = false.obs;
  double _mouseX = 0, _mouseY = 0;

  @override
  Widget build(BuildContext context) {
    Friend sender = widget.sender ?? Friend.system();
    final container = SpaceConnectionContainer.fromJson(jsonDecode(widget.message.content));

    return RepaintBoundary(
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        // This tracks the mouse for where the context menu should be
        onHover: (event) {
          _mouseX = event.position.dx;
          _mouseY = event.position.dy;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,

          // Open the context menu when right-clicking on the message
          onSecondaryTap: () {
            final menuData = ContextMenuData.fromPosition(Offset(_mouseX, _mouseY));

            // Open the context menu
            Get.dialog(MessageOptionsWindow(
              data: menuData,
              self: widget.message.senderAddress == StatusController.ownAddress,
              message: widget.message,
              provider: widget.provider,
            ));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: elementSpacing,
            ),
            child: Row(
              textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar of the message sender with a tooltip to know their name
                Tooltip(
                  message: sender.displayName.value,
                  child: UserAvatar(id: sender.id, size: 34),
                ),
                horizontalSpacing(defaultSpacing),

                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: widget.self ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        textDirection: widget.self ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(defaultSpacing),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(defaultSpacing),
                                color: widget.self ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primaryContainer,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.public, color: Get.theme.colorScheme.onPrimary),
                                      horizontalSpacing(elementSpacing),
                                      Flexible(
                                        child: Text(
                                          "chat.space_invite".tr,
                                          style: Get.theme.textTheme.labelLarge,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Render the member preview for Spaces
                                  verticalSpacing(defaultSpacing),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 350,
                                    ),
                                    child: SpaceRenderer(
                                      container: container,
                                      clickable: true,
                                      pollNewData: true,
                                      background:
                                          widget.self ? Get.theme.colorScheme.onPrimary.withOpacity(0.13) : Get.theme.colorScheme.inverseSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Show a timestamp straight after the message
                          horizontalSpacing(defaultSpacing),
                          Padding(
                            padding: const EdgeInsets.only(top: defaultSpacing),
                            child: SelectionContainer.disabled(
                              child: Text(formatMessageTime(widget.message.createdAt), style: Get.theme.textTheme.bodySmall),
                            ),
                          ),

                          // Show a warning in case the message couldn't be verified
                          horizontalSpacing(defaultSpacing),
                          Obx(() {
                            final verified = widget.message.verified.value;
                            return Visibility(
                              visible: !verified,
                              child: Padding(
                                padding: const EdgeInsets.only(top: elementSpacing + elementSpacing / 4),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
