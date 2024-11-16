import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MessageList extends StatefulWidget {
  final MessageProvider provider;
  final double? overwritePadding;

  const MessageList({super.key, required this.provider, this.overwritePadding});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _scrollController = AutoScrollController();

  @override
  void initState() {
    widget.provider.newScrollController(_scrollController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.provider.checkCurrentScrollHeight();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnEnd: 0,
              child: ListView.builder(
                itemCount: widget.provider.messages.length + 2,
                reverse: true,
                controller: _scrollController,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: (context, index) {
                  return BubblesRenderer(
                    index: index,
                    controller: _scrollController,
                    provider: widget.provider,
                    mobileLayout: constraints.maxWidth <= 800,
                    overwritePadding: widget.overwritePadding,
                  );
                },
              ),
            ),
          );
        });
      },
    );
  }
}
