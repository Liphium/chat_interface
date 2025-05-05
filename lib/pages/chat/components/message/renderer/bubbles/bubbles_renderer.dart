import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_zap_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_message_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_space_renderer.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_system_renderer.dart';
import 'package:chat_interface/services/chat/conversation_message_provider.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/message_options_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lorien_chat_list/lorien_chat_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:signals/signals_flutter.dart';

class BubblesRenderer extends StatefulWidget {
  final Message message;
  final MessageProvider provider;
  final AutoScrollController controller;
  final double heightMultiplier;
  final ChatListItemProperties properties;

  // Design of the bubbles
  final bool mobileLayout;

  const BubblesRenderer({
    super.key,
    required this.controller,
    required this.properties,
    required this.provider,
    required this.message,
    this.mobileLayout = false,
    this.heightMultiplier = 1.0,
  });

  @override
  State<BubblesRenderer> createState() => _BubblesRendererState();
}

class _BubblesRendererState extends State<BubblesRenderer> with TickerProviderStateMixin, SignalsMixin {
  final GlobalKey contextMenuKey = GlobalKey();
  final hovering = signal(false);
  Message? _message;

  @override
  void dispose() {
    _message?.highlightAnimation?.dispose();
    _message?.highlightAnimation = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    // Evaluate whether we need a heading
    bool lastMessage = false;
    bool readHeading = false;
    bool last = widget.properties.isAtTopEdge;
    bool newHeading = false;
    final nextMessageId = widget.provider.getNextMessageId(widget.properties.index);
    if (nextMessageId != null && widget.provider.messages[nextMessageId] != null) {
      final nextMessage = widget.provider.messages[nextMessageId]!;

      // Check if the last message was a day before the current one
      if (nextMessage.createdAt.day != message.createdAt.day) {
        newHeading = true;
        lastMessage = true;
      }

      // Check if we should render the profile picture
      if (nextMessage.senderAddress != message.senderAddress) {
        lastMessage = true;
      }

      // See if we need a heading to indicate messages below it are not read
      if (widget.provider is ConversationMessageProvider) {
        final provider = widget.provider as ConversationMessageProvider;
        final readTime = provider.conversation.reads.get(provider.extra);
        if (readTime < message.createdAt.millisecondsSinceEpoch &&
            readTime > nextMessage.createdAt.millisecondsSinceEpoch) {
          readHeading = true;
        }
      }
    } else {
      lastMessage = true;
    }

    // Make sure to also show it when there are no messages before the current one
    if (nextMessageId == null && widget.provider is ConversationMessageProvider) {
      final provider = widget.provider as ConversationMessageProvider;
      final readTime = provider.conversation.reads.get(provider.extra);
      if (readTime < message.createdAt.millisecondsSinceEpoch) {
        readHeading = true;
      }
    }

    if (message.type == MessageType.system) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (newHeading || last) renderHeightTag(message),
          if (readHeading) renderRead(message, newHeading || last),
          BubblesSystemMessageRenderer(message: message, provider: widget.provider),
        ],
      );
    }
    final sender = FriendController.friends[message.senderAddress];
    final self = message.senderAddress == StatusController.ownAddress;

    final Widget renderer;
    switch (message.type) {
      case MessageType.text:
        renderer = BubblesMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          senderAddress: message.senderAddress,
          self: self,
          last: lastMessage,
          sender: self ? Friend.me() : sender,
          mobileLayout: widget.mobileLayout,
        );

      case MessageType.call:
        renderer = BubblesSpaceMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          self: self,
          last: lastMessage,
          sender: self ? Friend.me() : sender,
          mobileLayout: widget.mobileLayout,
        );

      case MessageType.liveshare:
        renderer = BubblesLiveshareMessageRenderer(
          key: ValueKey(message.id),
          message: message,
          provider: widget.provider,
          self: self,
          sender: self ? Friend.me() : sender,
          mobileLayout: widget.mobileLayout,
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

    return AutoScrollTag(
      index: widget.properties.index,
      key: ValueKey("${message.id}-tag"),
      controller: widget.controller,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (newHeading || last) renderHeightTag(message),
          if (readHeading) renderRead(message, newHeading || last),
          MouseRegion(
            onEnter: (event) {
              hovering.value = true;
              MessageController.hoveredMessage = message;
            },
            onHover: (event) {
              if (hovering.value) {
                return;
              }
              hovering.value = true;
            },
            onExit: (event) {
              hovering.value = false;
              MessageController.hoveredMessage = null;
            },
            child: Row(
              textDirection: self ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Flexible(
                  child: Animate(
                    controller: message.highlightAnimation,
                    effects: [
                      ScaleEffect(
                        begin: Offset(1, 1),
                        end: Offset(1.15, 1.15),
                        curve: Curves.ease,
                        alignment: self ? Alignment.centerRight : Alignment.centerLeft,
                      ),
                    ],
                    target: 0,
                    child: renderer,
                  ),
                ),
                if (!widget.mobileLayout) renderOverlay(self, message),
                if (widget.mobileLayout && !GetPlatform.isMobile) renderOverlay(self, message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderHeightTag(Message message) {
    return Padding(
      padding: const EdgeInsets.only(top: sectionSpacing, bottom: defaultSpacing),
      child: Text(formatDay(message.createdAt), style: Get.theme.textTheme.bodyMedium),
    );
  }

  Widget renderRead(Message message, bool heading) {
    return Padding(
      padding: EdgeInsets.only(top: heading ? 0 : defaultSpacing, bottom: elementSpacing),
      child: Row(
        children: [
          Expanded(child: Container(height: 2, color: Get.theme.colorScheme.error)),
          horizontalSpacing(defaultSpacing),
          Text("unread.messages".tr, style: Get.textTheme.labelMedium),
          horizontalSpacing(defaultSpacing),
          Expanded(child: Container(height: 2, color: Get.theme.colorScheme.error)),
        ],
      ),
    );
  }

  Widget renderOverlay(bool self, Message message) {
    return Watch(
      (ctx) => SizedBox(
        height: 34,
        child: Visibility(
          visible: hovering.value,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
