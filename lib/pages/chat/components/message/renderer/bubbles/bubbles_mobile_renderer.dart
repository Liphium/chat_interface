import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_liveshare_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_space_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/system_message_renderer.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class BubblesMobileRenderer extends StatefulWidget {
  final int index;
  final Message? message;
  final AutoScrollController controller;

  const BubblesMobileRenderer({
    super.key,
    required this.index,
    required this.controller,
    this.message,
  });

  @override
  State<BubblesMobileRenderer> createState() => _BubblesRendererState();
}

class _BubblesRendererState extends State<BubblesMobileRenderer> with TickerProviderStateMixin {
  final GlobalKey _heightKey = GlobalKey();
  final GlobalKey contextMenuKey = GlobalKey();
  final hovering = false.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final friendController = Get.find<FriendController>();

    // This is needed for jump to message
    if (widget.index == controller.messages.length + 1) {
      return SizedBox(
        height: Get.height,
      );
    }

    // Just to have some spacing above the actual message input
    if (widget.index == 0 && widget.message == null) {
      return verticalSpacing(defaultSpacing);
    }

    //* Chat bubbles
    final message = widget.message ?? controller.messages[widget.index - 1];

    if (message.heightCallback && !message.heightReported) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        sendLog(_heightKey.currentContext!.size!.height);
        message.heightReported = true;
        message.heightKey = _heightKey;
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

    final messageWidget = AutoScrollTag(
      index: widget.index,
      key: ValueKey(message.id),
      controller: widget.controller,
      child: SizedBox(
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
            Row(
              textDirection: self ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Flexible(
                  child: renderer,
                ),
              ],
            ),
          ],
        ),
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
