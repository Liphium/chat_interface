import 'dart:async';
import 'dart:math';

import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
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
    addRow();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        addRow();
        return;
      }
    });
  }

  @override
  void dispose() {
    gone = true;
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void addRow() {
    currentTimer?.cancel();
    final query = _currentSearch.value == "" ? UnicodeEmojis.allEmojis : UnicodeEmojis.search(_currentSearch.value);
    if (query.length <= currentIndex * 10) {
      return;
    }
    emojis.addAll(query.sublist(currentIndex * 10, min((currentIndex + 1) * 10, query.length)));
    currentIndex++;
    final currentQuery = _currentSearch.value;
    if (query.length <= currentIndex * 10) {
      return;
    }

    currentTimer = Timer(100.ms, () {
      if (gone || currentQuery != _currentSearch.value) {
        return;
      }
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        addRow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlidingWindowBase(
      position: widget.data,
      maxSize: 500,
      child: Column(
        children: [
          FJTextField(
            controller: _controller,
            prefixIcon: Icons.search,
            animation: false,
            autofocus: true,
            hintText: "Search emojis",
            onChange: (value) {
              _currentSearch.value = value;
              emojis.clear();
              currentIndex = 0;
              addRow();
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
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 30 * 1.5,
                      crossAxisSpacing: elementSpacing,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      if (index == emojis.length) {
                        return null;
                      }
                      final emoji = emojis[index];
                      return Tooltip(
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
                              style: Get.theme.textTheme.titleLarge!.copyWith(fontFamily: "Emoji", fontSize: 30),
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
