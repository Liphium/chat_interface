import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_liveshare_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/message_space_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/system_message_renderer.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class BubblesRenderer extends StatefulWidget {
  final int index;
  final Message? message;
  final MessageProvider provider;
  final AutoScrollController controller;

  // Design of the bubbles
  final bool mobileLayout;
  final double? overwritePadding;

  const BubblesRenderer({
    super.key,
    required this.index,
    required this.controller,
    required this.provider,
    this.message,
    this.mobileLayout = false,
    this.overwritePadding,
  });

  @override
  State<BubblesRenderer> createState() => _BubblesRendererState();
}

class _BubblesRendererState extends State<BubblesRenderer> with TickerProviderStateMixin {
  final GlobalKey _heightKey = GlobalKey();
  final GlobalKey contextMenuKey = GlobalKey();
  final hovering = false.obs;
  Message? _message;

  @override
  void dispose() {
    _message?.highlightAnimation?.dispose();
    _message?.highlightAnimation = null;
    super.dispose();
  }

  /// Called when the height should be reported back to the message controller
  void heightCallback(Message message, Duration timeStamp) {
    if (_heightKey.currentContext == null) {
      sendLog("couldn't find height, this message has been disposed");
      return;
    }

    // Report the actual height to the controller to scroll up the viewport
    message.heightReported = true;
    message.heightKey = _heightKey;
    widget.provider.messageHeightCallback(message, _heightKey.currentContext!.size!.height);
  }

  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();

    // This is needed for jump to message
    if (widget.index == widget.provider.messages.length + 1) {
      return Obx(() {
        final loading = widget.provider.newMessagesLoading.value;
        return SizedBox(
          height: Get.height,
          child: Visibility(
            visible: !loading,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: sectionSpacing),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "chat.welcome.title".tr,
                        style: Get.theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      verticalSpacing(sectionSpacing),
                      Text(
                        "chat.welcome.desc".tr,
                        style: Get.theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    }

    // Just for spacing above the input and a loading indicator
    if (widget.index == 0 && widget.message == null) {
      return verticalSpacing(defaultSpacing);
    }

    //* Chat bubbles
    final message = widget.message ?? widget.provider.messages[widget.index - 1];

    // Call the height callback (in case requested, for keeping the viewport up to date with the scroll)
    if (message.heightCallback && !message.heightReported) {
      WidgetsBinding.instance.addPostFrameCallback((timestamp) => heightCallback(message, timestamp));
    }

    if (message.type == MessageType.system) {
      return BubblesSystemMessageRenderer(message: message, provider: widget.provider);
    }
    final sender = friendController.friends[message.senderAddress];
    final self = message.senderAddress == StatusController.ownAddress;

    bool last = false;
    bool newHeading = false;
    if (widget.index != widget.provider.messages.length) {
      final lastMessage = widget.provider.messages[widget.index];

      // Check if the last message was a day before the current one
      if (lastMessage.createdAt.day != message.createdAt.day) {
        newHeading = true;
      }
    }

    final Widget renderer;
    switch (message.type) {
      case MessageType.text:
        renderer = BubblesMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          senderAddress: message.senderAddress,
          self: self,
          last: last,
          sender: self ? Friend.me() : sender,
          mobileLayout: widget.mobileLayout,
          overwritePadding: widget.overwritePadding,
        );

      case MessageType.call:
        renderer = BubblesSpaceMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          self: self,
          last: last,
          sender: self ? Friend.me() : sender,
          mobileLayout: widget.mobileLayout,
          overwritePadding: widget.overwritePadding,
        );

      case MessageType.liveshare:
        renderer = BubblesLiveshareMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          self: self,
          sender: self ? Friend.me() : sender,
          mobileLayout: widget.mobileLayout,
          overwritePadding: widget.overwritePadding,
        );

      case MessageType.system:
        renderer = BubblesSystemMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          mobileLayout: widget.mobileLayout,
        );
    }

    _message ??= message;
    message.highlightAnimation ??= AnimationController(vsync: this);
    message.highlightCallback?.call();
    message.highlightCallback = null;
    final messageWidget = AutoScrollTag(
      index: widget.index,
      key: ValueKey("${message.id}-tag"),
      controller: widget.controller,
      child: SizedBox(
        key: _heightKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (newHeading || widget.index == widget.provider.messages.length)
              Padding(
                padding: const EdgeInsets.only(top: sectionSpacing, bottom: defaultSpacing),
                child: Text(formatDay(message.createdAt), style: Get.theme.textTheme.bodyMedium),
              ),
            MouseRegion(
              onEnter: (event) {
                hovering.value = true;
                Get.find<MessageController>().hoveredMessage = message;
              },
              onHover: (event) {
                if (hovering.value) {
                  return;
                }
                hovering.value = true;
              },
              onExit: (event) {
                hovering.value = false;
                Get.find<MessageController>().hoveredMessage = null;
              },
              child: Row(
                textDirection: self ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Flexible(
                    child: Animate(
                      controller: message.highlightAnimation,
                      effects: [
                        ShimmerEffect(
                          duration: 1000.ms,
                          curve: Curves.ease,
                        ),
                      ],
                      target: 0,
                      child: renderer,
                    ),
                  ),
                  if (!widget.mobileLayout) renderOverlay(self, message),
                ],
              ),
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
            curve: Curves.ease,
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
      return Obx(() {
        return Align(
          alignment: Alignment.topCenter,
          heightFactor: message.canScroll.value ? 1 : 0,
          child: messageWidget,
        );
      });
    }

    return messageWidget;
  }

  Widget renderOverlay(bool self, Message message) {
    return Obx(
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
                      self: true,
                      message: message,
                      provider: widget.provider,
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
    );
  }
}
