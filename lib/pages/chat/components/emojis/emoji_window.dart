import 'dart:async';

import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class EmojiWindow extends StatefulWidget {
  final ContextMenuData data;

  const EmojiWindow({super.key, required this.data});

  @override
  State<EmojiWindow> createState() => _EmojiWindowState();
}

class _EmojiWindowState extends State<EmojiWindow> {
  final _scrollController = ScrollController();
  final _controller = TextEditingController();
  late final _emojis = listSignal(UnicodeEmojis.allEmojis.sublist(0, 100));
  Timer? _currentTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _emojis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emojiTextStyle = Get.theme.textTheme.titleLarge!.copyWith(fontSize: 30);

    return SlidingWindowBase(
      title: const [],
      position: widget.data,
      maxSize: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FJTextField(
            controller: _controller,
            prefixIcon: Icons.search,
            animation: false,
            autofocus: true,
            hintText: "Search emojis",
            onChange: (value) {
              _currentTimer?.cancel();
              _currentTimer = Timer(const Duration(milliseconds: 300), () {
                if (value == "") {
                  _emojis.value = UnicodeEmojis.allEmojis.sublist(0, 100);
                } else {
                  final search = UnicodeEmojis.search(value);
                  _emojis.value = search;
                }
              });
            },
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: Material(
                color: Colors.transparent,
                child: Watch(
                  (ctx) => FadingEdgeScrollView.fromScrollView(
                    child: GridView.builder(
                      primary: false,
                      key: const Key("emojiScrollView"),
                      scrollDirection: Axis.vertical,
                      controller: _scrollController,
                      padding: EdgeInsets.all(elementSpacing),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisCount: 6,
                        mainAxisSpacing: elementSpacing,
                        crossAxisSpacing: elementSpacing,
                      ),
                      itemCount: _emojis.length,
                      itemBuilder: (context, index) {
                        final emoji = _emojis[index];
                        return Tooltip(
                          waitDuration: const Duration(milliseconds: 500),
                          exitDuration: const Duration(milliseconds: 0),
                          message: ":${emoji.shortName}:",
                          child: Center(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(1000),
                              onTap: () {
                                Get.back(result: emoji.emoji);
                                _currentTimer?.cancel();
                              },
                              child: Text(emoji.emoji, style: emojiTextStyle),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
