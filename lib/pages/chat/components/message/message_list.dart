import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lorien_chat_list/lorien_chat_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:signals/signals_flutter.dart';

class MessageList extends StatefulWidget {
  final MessageProvider provider;
  final double? overwritePadding;
  final double heightMultiplier;

  const MessageList({super.key, required this.provider, this.overwritePadding, this.heightMultiplier = 1});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _scrollController = AutoScrollController();

  @override
  void initState() {
    widget.provider.newControllers(_scrollController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.provider.checkCurrentScrollHeight();
    });

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.overwritePadding ?? (constraints.maxWidth <= 800 ? defaultSpacing : sectionSpacing),
            ),
            child: ChatList(
              scrollController: _scrollController,
              controller: widget.provider.listController,
              loadingMoreWidget: SizedBox(),
              onLoadMoreCallback: () async {
                var (topReached, error) = await widget.provider.loadNewMessagesTop();
                if (!error) {
                  return topReached;
                }
                return false;
              },
              scrollPhysics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: (messageId, itemDetails) {
                return Watch((ctx) {
                  final message = widget.provider.messages[messageId];
                  if (message == null) {
                    return SizedBox();
                  }

                  return BubblesRenderer(
                    message: message,
                    properties: itemDetails,
                    controller: _scrollController,
                    provider: widget.provider,
                    mobileLayout: constraints.maxWidth <= 800,
                    heightMultiplier: widget.heightMultiplier,
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }
}
