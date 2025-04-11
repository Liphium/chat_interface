import 'dart:async';

import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  final _currentSearch = signal("");
  final _emojis = listSignal(<Emoji>[]);
  Timer? _currentTimer;

  @override
  void initState() {
    super.initState();
    _emojis.value = UnicodeEmojis.allEmojis;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _currentSearch.dispose();
    _emojis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emojiTextStyle = Get.theme.textTheme.titleLarge!.copyWith(fontSize: 30);

    return SlidingWindowBase(
      title: const [],
      position: widget.data,
      maxSize: 500,
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
              _currentSearch.value = value;
              if (value == "") {
                _emojis.value = UnicodeEmojis.allEmojis;
              } else {
                final search = UnicodeEmojis.search(value);
                _emojis.value = search;
              }
            },
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: Get.height * 0.5),
            child: Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: Material(
                color: Colors.transparent,
                child: Watch(
                  (ctx) => GridView.builder(
                    key: const ValueKey("the grid"),
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 30 * 1.5, crossAxisSpacing: elementSpacing),
                    itemCount: _emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = _emojis[index];
                      return RepaintBoundary(
                        child: Tooltip(
                          key: ValueKey(emoji.shortName),
                          waitDuration: 500.ms,
                          exitDuration: 0.ms,
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
                        ),
                      );
                    },
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
