import 'dart:async';

import 'package:chat_interface/theme/components/forms/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
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
  final _currentSearch = "".obs;
  int currentIndex = 0;
  final emojis = <Emoji>[].obs;
  bool gone = false;
  Timer? currentTimer;

  @override
  void initState() {
    super.initState();
    emojis.value = UnicodeEmojis.allEmojis;
  }

  @override
  void dispose() {
    gone = true;
    _scrollController.dispose();
    _controller.dispose();
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
                emojis.value = UnicodeEmojis.allEmojis;
              } else {
                final search = UnicodeEmojis.search(value);
                emojis.value = search;
              }
            },
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: Get.height * 0.5),
            child: Padding(
              padding: const EdgeInsets.only(top: defaultSpacing),
              child: Material(
                color: Colors.transparent,
                child: Obx(
                  () => GridView.builder(
                    key: const ValueKey("the grid"),
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 30 * 1.5,
                      crossAxisSpacing: elementSpacing,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
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
                                currentTimer?.cancel();
                              },
                              child: Text(
                                emoji.emoji,
                                style: emojiTextStyle,
                              ),
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
