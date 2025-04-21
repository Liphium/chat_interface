import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/bubbles/bubbles_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:lorien_chat_list/lorien_chat_list.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MessageList extends StatefulWidget {
  final MessageProvider provider;
  final double? overwritePadding;
  final double heightMultiplier;

  const MessageList({
    super.key,
    required this.provider,
    this.overwritePadding,
    this.heightMultiplier = 1,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final _scrollController = AutoScrollController();
  late final _chatListController = ChatListController<int>(initialItems: getIndecies());

  List<int> getIndecies() {
    final list = <int>[];
    int index = 0;
    for(var _ in widget.provider.messages) {
      list.add(index);
    }
    return list;
  }

  @override
  void initState() {
    widget.provider.newControllers(_scrollController, _chatListController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.provider.checkCurrentScrollHeight();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                widget.overwritePadding ??
                (constraints.maxWidth <= 800 ? defaultSpacing : sectionSpacing),
          ),
          child: ChatList(
            scrollController: _scrollController,
            controller: ,
            ,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemBuilder: (index, itemDetails) {
              return BubblesRenderer(
                index: index as int,
                message: ,
                controller: _scrollController,
                provider: widget.provider,
                mobileLayout: constraints.maxWidth <= 800,
                heightMultiplier: widget.heightMultiplier,
              );
            },
          ),
        );
      },
    );
  }
}
