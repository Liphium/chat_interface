import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/message_feed.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_liveshare_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_space_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/system_message_renderer.dart';
import 'package:chat_interface/theme/components/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class BubblesRenderer extends StatefulWidget {
  final int index;
  final Message? message;

  const BubblesRenderer({
    super.key,
    required this.index,
    this.message,
  });

  @override
  State<BubblesRenderer> createState() => _BubblesRendererState();
}

class _BubblesRendererState extends State<BubblesRenderer> with TickerProviderStateMixin {
  final GlobalKey _heightKey = GlobalKey();
  final GlobalKey contextMenuKey = GlobalKey();
  final hovering = false.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final friendController = Get.find<FriendController>();

    //* Chat bubbles
    if (widget.index == 0 && widget.message == null) {
      return verticalSpacing(defaultSpacing);
    }

    final message = widget.message ?? controller.messages[widget.index - 1];

    if (message.heightCallback) {
      sendLog("HEIGHT CALLBACK");
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        sendLog(_heightKey.currentContext!.size!.height);
        Get.find<MessageController>().messageHeightCallback(message, _heightKey.currentContext!.size!.height);
      });
    }

    if (message.type == MessageType.system) {
      return BubblesSystemMessageRenderer(message: message, accountId: MessageController.systemSender);
    }
    final sender = friendController.friends[message.senderAccount];
    final self = message.senderAccount == StatusController.ownAccountId;

    bool last = false;
    bool newHeading = false;
    if (widget.index != controller.messages.length) {
      final lastMessage = controller.messages[widget.index];

      // Check if the last message was a day before the current one
      if (lastMessage.createdAt.day != message.createdAt.day) {
        newHeading = true;
      }
    }

    final Widget renderer;
    switch (message.type) {
      case MessageType.text:
        renderer = BubblesMessageRenderer(
          message: message,
          accountId: message.senderAccount,
          self: self,
          last: last,
          sender: self ? Friend.me() : sender,
        );

      case MessageType.call:
        renderer = BubblesSpaceMessageRenderer(
          message: message,
          self: self,
          last: last,
          sender: self ? Friend.me() : sender,
        );

      case MessageType.liveshare:
        renderer = BubblesLiveshareMessageRenderer(
          message: message,
          self: self,
          last: last,
          sender: self ? Friend.me() : sender,
        );

      case MessageType.system:
        renderer = BubblesSystemMessageRenderer(
          message: message,
          accountId: message.senderAccount,
        );
    }

    final messageWidget = SizedBox(
      key: _heightKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        key: ValueKey(message.id),
        children: [
          if (newHeading || widget.index == controller.messages.length)
            Padding(
              padding: const EdgeInsets.only(top: sectionSpacing, bottom: defaultSpacing),
              child: Text(formatDay(message.createdAt), style: Get.theme.textTheme.bodyMedium),
            ),
          MouseRegion(
            onEnter: (event) => hovering.value = true,
            onHover: (event) {
              if (hovering.value) {
                return;
              }
              hovering.value = true;
            },
            onExit: (event) => hovering.value = false,
            child: Row(
              textDirection: self ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Flexible(
                  child: renderer,
                ),
                Obx(
                  () => SizedBox(
                    height: 34,
                    child: Visibility(
                      visible: hovering.value,
                      child: Row(
                        children: [
                          LoadingIconButton(
                            key: contextMenuKey,
                            iconSize: 22,
                            extra: 4,
                            padding: 4,
                            onTap: () {
                              Get.dialog(
                                MessageOptionsWindow(
                                  data: ContextMenuData.fromKey(contextMenuKey),
                                  self: self,
                                  message: message,
                                ),
                              );
                            },
                            icon: Icons.more_horiz,
                          ),
                          LoadingIconButton(
                            iconSize: 22,
                            extra: 4,
                            padding: 4,
                            onTap: () {
                              MessageSendHelper.addReplyToCurrentDraft(message);
                            },
                            icon: Icons.reply,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (message.playAnimation) {
      message.initAnimation(this);
      return Animate(
        effects: [
          ExpandEffect(
            alignment: Alignment.center,
            duration: 250.ms,
            curve: scaleAnimationCurve,
            axis: Axis.vertical,
          ),
          FadeEffect(
            begin: 0,
            end: 1,
            duration: 500.ms,
          ),
        ],
        autoPlay: false,
        controller: message.controller!,
        onComplete: (controller) => message.playAnimation = false,
        child: messageWidget,
      );
    }

    if (message.heightCallback) {
      return Obx(
        () => Align(
          alignment: Alignment.topCenter,
          heightFactor: message.canScroll.value ? 1 : 0,
          child: messageWidget,
        ),
      );
    }

    return Align(
      heightFactor: 1,
      alignment: Alignment.topCenter,
      child: messageWidget,
    );
  }
}
