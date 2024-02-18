import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twemoji_v2/twemoji_v2.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

class EmojiWindow extends StatefulWidget {
  const EmojiWindow({super.key});

  @override
  State<EmojiWindow> createState() => _EmojiWindowState();
}

class _EmojiWindowState extends State<EmojiWindow> {
  @override
  Widget build(BuildContext context) {
    return DialogBase(
      maxWidth: 500,
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 100,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: Get.theme.textTheme.titleLarge!.fontSize! * 1.5),
        itemBuilder: (context, index) {
          final emoji = UnicodeEmojis.allEmojis[index];
          return TwemojiText(
            text: emoji.emoji,
            style: Get.theme.textTheme.titleLarge,
          );
        },
      ),
    );
  }
}
